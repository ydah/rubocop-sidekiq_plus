# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for mixed ActiveJob and Sidekiq retry strategies in the same job.
      #
      # @example
      #   # bad
      #   class MyJob < ApplicationJob
      #     retry_on SomeError
      #     sidekiq_options retry: 5
      #   end
      #
      class MixedRetryStrategies < Base
        MSG = 'Avoid mixing ActiveJob retry_on with Sidekiq retry options.'

        def on_class(node)
          return unless active_job_class?(node)
          return unless retry_on_call?(node)

          sidekiq_retry_option_nodes(node).each do |send|
            add_offense(send)
          end
        end

        private

        def retry_on_call?(class_node)
          class_node.each_descendant(:send).any? { |send| send.method_name == :retry_on }
        end

        def sidekiq_retry_option_nodes(class_node)
          class_node.each_descendant(:send).select do |send|
            sidekiq_options_call?(send) { |args| retry_option?(args) }
          end
        end

        def retry_option?(args)
          args.any? do |arg|
            next false unless arg.hash_type?

            arg.pairs.any? do |pair|
              key = pair.key
              next false unless key&.sym_type? && key.value == :retry

              value = pair.value
              !value.false_type?
            end
          end
        end
      end
    end
  end
end
