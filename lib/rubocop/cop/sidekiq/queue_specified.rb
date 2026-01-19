# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks that Sidekiq jobs have an explicit queue specified.
      #
      # Without an explicit queue, jobs go to the `default` queue.
      # Specifying queues helps with job organization and prioritization.
      #
      # @example
      #   # bad
      #   class MyJob
      #     include Sidekiq::Job
      #   end
      #
      #   # good
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options queue: :critical
      #   end
      #
      class QueueSpecified < Base
        MSG = 'Specify a queue for this Sidekiq job using `sidekiq_options queue: :queue_name`.'

        def_node_matcher :sidekiq_include?, <<~PATTERN
          (send nil? :include (const (const {nil? cbase} :Sidekiq) {:Job :Worker}))
        PATTERN

        def_node_matcher :sidekiq_options_with_queue?, <<~PATTERN
          (send nil? :sidekiq_options (hash <(pair (sym :queue) _) ...>))
        PATTERN

        def on_class(node)
          return unless sidekiq_job_class?(node)
          return if queue_option?(node)

          include_node = find_sidekiq_include(node)
          add_offense(include_node) if include_node
        end

        private

        def sidekiq_job_class?(class_node)
          return false unless class_node.body

          find_sidekiq_include(class_node)
        end

        def find_sidekiq_include(class_node)
          return nil unless class_node.body

          if class_node.body.begin_type?
            class_node.body.each_child_node.find { |n| sidekiq_include?(n) }
          elsif sidekiq_include?(class_node.body)
            class_node.body
          end
        end

        def queue_option?(class_node)
          return false unless class_node.body

          if class_node.body.begin_type?
            class_node.body.each_child_node.any? { |n| sidekiq_options_with_queue?(n) }
          else
            sidekiq_options_with_queue?(class_node.body)
          end
        end
      end
    end
  end
end
