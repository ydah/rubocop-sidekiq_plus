# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that concurrent limiters specify lock_timeout option.
      #
      # Without lock_timeout, the default (30 seconds) may not cover jobs
      # with longer execution times, causing locks to expire prematurely.
      #
      # @example
      #   # bad - no lock_timeout specified
      #   LIMITER = Sidekiq::Limiter.concurrent('erp', 50, wait_timeout: 0)
      #
      #   # good - explicit lock_timeout
      #   LIMITER = Sidekiq::Limiter.concurrent('erp', 50, wait_timeout: 0, lock_timeout: 120)
      #
      class LimiterWithoutLockTimeout < Base
        MSG = 'Specify `lock_timeout` option for concurrent limiters to match job execution time.'

        def on_send(node)
          limiter_creation?(node) do |method, _name, _limit|
            return unless method == :concurrent
            return if lock_timeout_option?(node)

            add_offense(node)
          end
        end
        alias on_csend on_send

        private

        def lock_timeout_option?(node)
          options_hash = find_options_hash(node)
          return false unless options_hash

          options_hash.pairs.any? { |pair| pair.key.value == :lock_timeout }
        end

        def find_options_hash(node)
          node.arguments.find(&:hash_type?)
        end
      end
    end
  end
end
