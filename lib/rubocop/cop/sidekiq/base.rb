# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Base class for Sidekiq cops.
      class Base < ::RuboCop::Cop::Base
        # Common patterns for Sidekiq job classes
        def_node_matcher :sidekiq_include?, <<~PATTERN
          (send nil? :include (const (const nil? :Sidekiq) {:Job :Worker}))
        PATTERN

        def_node_matcher :sidekiq_options_call?, <<~PATTERN
          (send nil? :sidekiq_options $...)
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
          class_node.body&.each_child_node&.any? { |n| sidekiq_include?(n) }
        end
      end
    end
  end
end
