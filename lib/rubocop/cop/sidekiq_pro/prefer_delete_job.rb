# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Recommends using Sidekiq Pro's `delete_job` or `delete_by_class` methods
      # instead of iterating through queues and deleting jobs manually.
      #
      # Manual iteration and deletion has race conditions and is not scalable.
      # Sidekiq Pro provides atomic operations that are safer and more efficient.
      #
      # @example
      #   # bad - iterating and deleting jobs
      #   Sidekiq::Queue.new.each do |job|
      #     job.delete if job.jid == target_jid
      #   end
      #
      #   # bad - using select then delete
      #   Sidekiq::Queue.new.select { |job| job.item['class'] == 'MyJob' }.each(&:delete)
      #
      #   # good - use Sidekiq Pro's delete_job
      #   Sidekiq::Queue.new('default').delete_job(jid)
      #
      #   # good - use Sidekiq Pro's delete_by_class
      #   Sidekiq::Queue.new('default').delete_by_class('MyJob')
      #
      class PreferDeleteJob < Base
        MSG = 'Consider using Sidekiq Pro\'s `delete_job` or `delete_by_class` ' \
              'instead of iterating and deleting jobs manually.'

        SIDEKIQ_QUEUE_CLASSES = %w[
          Queue
          RetrySet
          ScheduledSet
          DeadSet
        ].freeze

        ITERATION_METHODS = %i[each select find map reject].freeze

        # @!method queue_iteration_with_delete?(node)
        def_node_matcher :queue_iteration_with_delete?, <<~PATTERN
          (block
            (send
              (send (const (const {nil? cbase} :Sidekiq) {#{SIDEKIQ_QUEUE_CLASSES.map { |c| ":#{c}" }.join(' ')}}) :new ...)
              {#{ITERATION_METHODS.map(&:inspect).join(' ')}}
            )
            _args
            `(send _ :delete ...)
          )
        PATTERN

        # @!method chained_select_delete?(node)
        def_node_matcher :chained_select_delete?, <<~PATTERN
          (send
            (block
              (send
                (send (const (const {nil? cbase} :Sidekiq) {#{SIDEKIQ_QUEUE_CLASSES.map { |c| ":#{c}" }.join(' ')}}) :new ...)
                {#{ITERATION_METHODS.map(&:inspect).join(' ')}}
              )
              _args
              _body
            )
            {:each :map}
            (block_pass (sym :delete))
          )
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless queue_iteration_with_delete?(node)

          add_offense(node)
        end

        def on_send(node)
          return unless chained_select_delete?(node)

          add_offense(node)
        end
        alias on_csend on_send
      end
    end
  end
end
