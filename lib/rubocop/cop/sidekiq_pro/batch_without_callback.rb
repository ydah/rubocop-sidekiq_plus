# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks that batches have callbacks or descriptions for tracking.
      #
      # Batches without callbacks or descriptions are difficult to track
      # and monitor. Consider adding at least one callback or a description.
      #
      # @example
      #   # bad - no callback or description
      #   batch = Sidekiq::Batch.new
      #   batch.jobs do
      #     SomeJob.perform_async
      #   end
      #
      #   # good - has callback
      #   batch = Sidekiq::Batch.new
      #   batch.on(:complete, MyCallback)
      #   batch.jobs do
      #     SomeJob.perform_async
      #   end
      #
      #   # good - has description
      #   batch = Sidekiq::Batch.new
      #   batch.description = "Import users"
      #   batch.jobs do
      #     SomeJob.perform_async
      #   end
      #
      class BatchWithoutCallback < Base
        MSG = 'Batch should have a callback or description for tracking.'

        def on_block(node)
          return unless batch_jobs_block?(node)

          batch_receiver = node.send_node.receiver
          return unless batch_receiver

          batch_var_name = extract_variable_name(batch_receiver)
          return unless batch_var_name

          add_offense(node.send_node) unless callback_or_description?(node, batch_var_name)
        end

        private

        def extract_variable_name(node)
          case node.type
          when :lvar
            node.children.first
          when :send
            node.method_name if node.receiver.nil?
          end
        end

        def callback_or_description?(jobs_block, batch_var_name)
          parent_scope = find_parent_scope(jobs_block)
          return false unless parent_scope

          parent_scope.each_descendant(:send).any? do |send_node|
            receiver_matches?(send_node, batch_var_name) &&
              %i[on description=].include?(send_node.method_name)
          end
        end

        def receiver_matches?(send_node, batch_var_name)
          return false unless send_node.receiver

          case send_node.receiver.type
          when :lvar
            send_node.receiver.children.first == batch_var_name
          when :send
            send_node.receiver.method_name == batch_var_name
          else
            false
          end
        end

        def find_parent_scope(node)
          node.each_ancestor(:def, :defs, :block, :begin).first ||
            node.each_ancestor.find { |n| n.type == :begin }
        end
      end
    end
  end
end
