# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks that jobs enqueued in batch callbacks have retry enabled.
      #
      # When a batch succeeds but the callback job fails without retry,
      # the overall workflow may be incomplete without any automatic recovery.
      #
      # @example
      #   # bad - callback enqueues a job without retry
      #   class MyCallback
      #     def on_success(status, options)
      #       FinalizeJob.perform_async(options['order_id'])
      #     end
      #   end
      #
      #   class FinalizeJob
      #     include Sidekiq::Job
      #     sidekiq_options retry: false
      #   end
      #
      #   # good - callback enqueues a job with retry enabled
      #   class FinalizeJob
      #     include Sidekiq::Job
      #     sidekiq_options retry: 5
      #   end
      #
      class BatchRetryInCallback < Base
        MSG = 'Jobs enqueued in batch callbacks should have retry enabled.'

        # @!method callback_method?(node)
        def_node_matcher :callback_method?, <<~PATTERN
          (def {:on_complete :on_success :on_death} (args _ _) ...)
        PATTERN

        # @!method perform_async_call?(node)
        def_node_matcher :perform_async_call?, <<~PATTERN
          (send (const ...) {:perform_async :perform_in :perform_at} ...)
        PATTERN

        def on_def(node)
          return unless callback_method?(node)

          node.each_descendant(:send) do |send_node|
            add_offense(send_node) if perform_async_call?(send_node)
          end
        end
        alias on_defs on_def
      end
    end
  end
end
