# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks that nested batches have proper parent relationship.
      #
      # When creating nested batches inside a batch.jobs block,
      # the child batch should reference the parent for proper tracking.
      #
      # @example
      #   # bad - nested batch without parent reference
      #   class ProcessBatchJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       batch.jobs do
      #         child_batch = Sidekiq::Batch.new
      #         child_batch.jobs do
      #           SomeJob.perform_async
      #         end
      #       end
      #     end
      #   end
      #
      #   # good - explicit parent reference
      #   class ProcessBatchJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       parent_batch = batch
      #       parent_batch.jobs do
      #         child_batch = Sidekiq::Batch.new(parent_batch.bid)
      #         child_batch.jobs do
      #           SomeJob.perform_async
      #         end
      #       end
      #     end
      #   end
      #
      class NestedBatchWithoutParent < Base
        MSG = 'Nested batch should reference parent batch for proper tracking.'

        def on_block(node)
          return unless batch_jobs_block?(node)

          node.body&.each_descendant(:send) do |send_node|
            add_offense(send_node) if batch_new?(send_node) && send_node.arguments.empty?
          end
        end
      end
    end
  end
end
