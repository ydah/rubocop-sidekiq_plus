# frozen_string_literal: true

module RuboCop
  module Sidekiq
    # Centralized Sidekiq API definitions used by cops.
    module Language
      extend RuboCop::NodePattern::Macros

      module PerformMethods # :nodoc:
        ALL = %i[perform_async perform_in perform_at perform_bulk].freeze
        class << self
          def all(element = nil)
            return ALL if element.nil?

            ALL.include?(element)
          end
        end
      end

      module JobModules # :nodoc:
        ALL = %i[Job Worker].freeze
        class << self
          def all(element = nil)
            return ALL if element.nil?

            ALL.include?(element)
          end
        end
      end

      # @!method sidekiq_include?(node)
      def_node_matcher :sidekiq_include?, <<~PATTERN
        (send nil? :include (const (const {nil? cbase} :Sidekiq)
          {#{JobModules.all.map(&:inspect).join(' ')}}))
      PATTERN

      # @!method sidekiq_options_call?(node)
      def_node_matcher :sidekiq_options_call?, <<~PATTERN
        (send nil? :sidekiq_options $...)
      PATTERN

      # @!method active_job_class?(node)
      def_node_matcher :active_job_class?, <<~PATTERN
        (class _ (const {nil? cbase} :ApplicationJob) ...)
      PATTERN

      # @!method perform_call?(node)
      def_node_matcher :perform_call?, <<~PATTERN
        (send $_ {#{PerformMethods.all.map(&:inspect).join(' ')}} ...)
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
