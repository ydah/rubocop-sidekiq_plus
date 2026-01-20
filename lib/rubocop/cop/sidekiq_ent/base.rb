# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # @abstract
      # Base class for Sidekiq Enterprise cops.
      # Provides common functionality for detecting Enterprise-specific patterns.
      class Base < ::RuboCop::Cop::Base
        abstract! if respond_to?(:abstract!)
        include RuboCop::Sidekiq::Language

        # Detect Sidekiq::Limiter.concurrent/bucket/window/leaky
        # @!method limiter_creation?(node)
        def_node_matcher :limiter_creation?, <<~PATTERN
          (send
            (const (const {nil? cbase} :Sidekiq) :Limiter)
            ${:concurrent :bucket :window :leaky}
            $_
            $_
            ...
          )
        PATTERN

        # Detect sidekiq_options with unique_for
        # @!method unique_for_option?(node)
        def_node_matcher :unique_for_option?, <<~PATTERN
          (send nil? :sidekiq_options
            (hash <(pair (sym :unique_for) $_) ...>)
          )
        PATTERN

        # Detect sidekiq_options with unique_until
        # @!method unique_until_option?(node)
        def_node_matcher :unique_until_option?, <<~PATTERN
          (send nil? :sidekiq_options
            (hash <(pair (sym :unique_until) $_) ...>)
          )
        PATTERN
      end
    end
  end
end
