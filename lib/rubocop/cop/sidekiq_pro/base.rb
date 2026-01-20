# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # @abstract
      # Base class for Sidekiq Pro cops.
      # Provides common functionality for detecting Pro-specific patterns.
      class Base < ::RuboCop::Cop::Base
        abstract! if respond_to?(:abstract!)
        include RuboCop::Sidekiq::Language

        # Detect Sidekiq::Batch.new
        # @!method batch_new?(node)
        def_node_matcher :batch_new?, <<~PATTERN
          (send (const (const {nil? cbase} :Sidekiq) :Batch) :new ...)
        PATTERN

        # Detect batch.jobs block
        # @!method batch_jobs_block?(node)
        def_node_matcher :batch_jobs_block?, <<~PATTERN
          (block (send $_ :jobs) _ $_)
        PATTERN

        # Detect batch.on callback registration
        # @!method batch_on_callback?(node)
        def_node_matcher :batch_on_callback?, <<~PATTERN
          (send $_ :on (sym $_) $...)
        PATTERN

        # Detect batch.description= assignment
        # @!method batch_description_set?(node)
        def_node_matcher :batch_description_set?, <<~PATTERN
          (send $_ :description= $_)
        PATTERN
      end
    end
  end
end
