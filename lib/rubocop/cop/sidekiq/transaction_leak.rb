# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for Sidekiq jobs enqueued inside database transactions.
      #
      # Enqueuing jobs inside a transaction can lead to race conditions where
      # the job runs before the transaction commits, causing the job to see
      # stale data or fail to find the record.
      #
      # @example
      #   # bad
      #   ActiveRecord::Base.transaction do
      #     user.save!
      #     NotificationJob.perform_async(user.id)
      #   end
      #
      #   # good - enqueue after transaction
      #   user.save!
      #   NotificationJob.perform_async(user.id)
      #
      #   # good - use after_commit callback
      #   class User < ApplicationRecord
      #     after_commit :send_notification, on: :create
      #
      #     def send_notification
      #       NotificationJob.perform_async(id)
      #     end
      #   end
      #
      class TransactionLeak < Base
        MSG = 'Do not enqueue Sidekiq jobs inside database transactions. ' \
              'The job may run before the transaction commits.'

        PERFORM_METHODS = %i[perform_async perform_in perform_at perform_bulk].freeze

        RESTRICT_ON_SEND = PERFORM_METHODS

        def_node_matcher :perform_call?, <<~PATTERN
          (send _ {#{PERFORM_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def on_send(node)
          return unless perform_call?(node)
          return unless inside_transaction?(node)

          add_offense(node)
        end

        private

        def inside_transaction?(node)
          node.each_ancestor(:block).any? do |block_node|
            transaction_block?(block_node)
          end
        end

        def transaction_block?(block_node)
          return false unless block_node.send_node

          transaction_call?(block_node.send_node)
        end

        def_node_matcher :transaction_call?, <<~PATTERN
          (send _ :transaction ...)
        PATTERN
      end
    end
  end
end
