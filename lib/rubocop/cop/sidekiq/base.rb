# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Base class for Sidekiq cops.
      class Base < ::RuboCop::Cop::Base
        # Common patterns for Sidekiq job classes
        def_node_matcher :sidekiq_include?, <<~PATTERN
          (send nil? :include (const (const {nil? cbase} :Sidekiq) {:Job :Worker}))
        PATTERN

        def_node_matcher :sidekiq_options_call?, <<~PATTERN
          (send nil? :sidekiq_options $...)
        PATTERN

        def_node_matcher :active_job_class?, <<~PATTERN
          (class _ (const {nil? cbase} :ApplicationJob) ...)
        PATTERN

        # Check if this node is a perform_async-style call
        def_node_matcher :perform_call?, <<~PATTERN
          (send $_ {:perform_async :perform_in :perform_at :perform_bulk} ...)
        PATTERN

        private

        def in_sidekiq_job?(node)
          node.each_ancestor(:class).any? do |class_node|
            sidekiq_job_class?(class_node)
          end
        end

        def sidekiq_job_class?(class_node)
          return false unless class_node.body

          if class_node.body.begin_type?
            class_node.body.each_child_node.any? { |n| sidekiq_include?(n) }
          else
            sidekiq_include?(class_node.body)
          end
        end
      end
    end
  end
end
