# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks for large arguments passed to jobs within a batch.
      #
      # When using batches, passing large arguments to jobs is especially
      # problematic because it can exhaust Redis memory when many jobs
      # are enqueued simultaneously.
      #
      # @example
      #   # bad
      #   batch.jobs do
      #     items.each do |item|
      #       ProcessJob.perform_async(item.attributes)
      #     end
      #   end
      #
      #   # good
      #   batch.jobs do
      #     items.each do |item|
      #       ProcessJob.perform_async(item.id)
      #     end
      #   end
      #
      class LargeArgumentInBatch < Base
        MSG = 'Avoid passing large arguments to jobs within a batch. Pass IDs instead.'

        DEFAULT_MAX_ARRAY_SIZE = 10
        DEFAULT_MAX_HASH_SIZE = 10

        def on_block(node)
          batch_jobs_block?(node) do |_receiver, body|
            check_body_for_large_arguments(body)
          end
        end

        alias on_numblock on_block

        private

        def check_body_for_large_arguments(body)
          return unless body

          find_perform_calls(body).each do |call|
            call.arguments.each do |arg|
              add_offense(arg) if large_argument?(arg)
            end
          end
        end

        def find_perform_calls(node, calls = [])
          return calls unless node.is_a?(::Parser::AST::Node)

          calls << node if node.send_type? && perform_call?(node)
          node.children.each { |child| find_perform_calls(child, calls) }
          calls
        end

        def large_argument?(arg)
          large_array?(arg) || large_hash?(arg) || attributes_call?(arg)
        end

        def large_array?(arg)
          return false unless arg.array_type?

          arg.values.size > max_array_size
        end

        def large_hash?(arg)
          return false unless arg.hash_type?

          arg.pairs.size > max_hash_size
        end

        def attributes_call?(arg)
          return false unless arg.send_type?

          %i[attributes as_json to_h to_hash].include?(arg.method_name)
        end

        def max_array_size
          cop_config.fetch('MaxArraySize', DEFAULT_MAX_ARRAY_SIZE)
        end

        def max_hash_size
          cop_config.fetch('MaxHashSize', DEFAULT_MAX_HASH_SIZE)
        end
      end
    end
  end
end
