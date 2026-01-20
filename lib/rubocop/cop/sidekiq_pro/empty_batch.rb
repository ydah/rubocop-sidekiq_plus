# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks for batch.jobs blocks that might be empty.
      #
      # Empty batches cause errors in Sidekiq Pro versions before 7.1.
      # Even in newer versions, creating empty batches is often unintentional.
      #
      # @example
      #   # bad - block might add no jobs
      #   batch = Sidekiq::Batch.new
      #   batch.jobs do
      #     items.each do |item|
      #       ProcessJob.perform_async(item.id) if item.active?
      #     end
      #   end
      #
      #   # good - ensure at least one job is added or check before creating batch
      #   active_items = items.select(&:active?)
      #   if active_items.any?
      #     batch = Sidekiq::Batch.new
      #     batch.jobs do
      #       active_items.each do |item|
      #         ProcessJob.perform_async(item.id)
      #       end
      #     end
      #   end
      #
      class EmptyBatch < Base
        MSG = 'Batch jobs block may be empty. Ensure jobs are added or guard against empty batches.'

        CONDITIONAL_METHODS = %i[if unless case].freeze

        def on_block(node)
          batch_jobs_block?(node) do |_receiver, body|
            add_offense(node) if potentially_empty_block?(body)
          end
        end

        alias on_numblock on_block

        private

        def potentially_empty_block?(body)
          return true if body.nil?
          return false if contains_unconditional_perform?(body)

          all_perform_calls_conditional?(body)
        end

        def contains_unconditional_perform?(node)
          return false unless node

          case node.type
          when :send
            check_send_node_for_perform(node)
          when :begin
            node.children.any? { |child| contains_unconditional_perform?(child) }
          else
            false
          end
        end

        def check_send_node_for_perform(node)
          return true if perform_call?(node)

          node.children.any? { |child| child.is_a?(::Parser::AST::Node) && contains_unconditional_perform?(child) }
        end

        def all_perform_calls_conditional?(node)
          return false unless node

          perform_calls = find_perform_calls(node)
          return false if perform_calls.empty?

          perform_calls.all? { |call| inside_conditional?(call) || inside_iterator_with_condition?(call) }
        end

        def find_perform_calls(node, calls = [])
          return calls unless node.is_a?(::Parser::AST::Node)

          calls << node if node.send_type? && perform_call?(node)
          node.children.each { |child| find_perform_calls(child, calls) }
          calls
        end

        def inside_conditional?(node)
          node.each_ancestor.any? do |ancestor|
            ancestor.type?(:if, :case, :case_match)
          end
        end

        def inside_iterator_with_condition?(node)
          node.each_ancestor(:block, :numblock).any? do |block|
            iterator_with_potential_empty_collection?(block)
          end
        end

        def iterator_with_potential_empty_collection?(block)
          send_node = block.send_node
          %i[each map select filter find_each find_in_batches].include?(send_node.method_name)
        end
      end
    end
  end
end
