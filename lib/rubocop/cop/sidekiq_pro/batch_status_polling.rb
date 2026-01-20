# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks for batch status polling anti-patterns.
      #
      # Polling batch status in a loop wastes resources and can cause
      # issues. Use batch callbacks instead.
      #
      # @example
      #   # bad - polling for status
      #   loop do
      #     status = Sidekiq::Batch::Status.new(bid)
      #     break if status.complete?
      #     sleep 5
      #   end
      #
      #   # good - use callbacks
      #   batch = Sidekiq::Batch.new
      #   batch.on(:complete, MyCallback)
      #   batch.jobs do
      #     SomeJob.perform_async
      #   end
      #
      class BatchStatusPolling < Base
        MSG = 'Avoid polling batch status. Use batch callbacks instead.'

        # @!method batch_status_new?(node)
        def_node_matcher :batch_status_new?, <<~PATTERN
          (send (const (const (const {nil? cbase} :Sidekiq) :Batch) :Status) :new ...)
        PATTERN

        # @!method status_complete_check?(node)
        def_node_matcher :status_complete_check?, <<~PATTERN
          (send _ {:complete? :pending :failures :total} ...)
        PATTERN

        def on_send(node)
          return unless batch_status_new?(node)
          return unless inside_loop?(node)

          add_offense(node)
        end
        alias on_csend on_send

        private

        def inside_loop?(node)
          node.each_ancestor.any? do |ancestor|
            loop_node?(ancestor)
          end
        end

        def loop_node?(node)
          return true if node.type?(:while, :until)
          return true if node.block_type? && loop_method?(node.send_node)

          false
        end

        def loop_method?(send_node)
          %i[loop each times].include?(send_node.method_name)
        end
      end
    end
  end
end
