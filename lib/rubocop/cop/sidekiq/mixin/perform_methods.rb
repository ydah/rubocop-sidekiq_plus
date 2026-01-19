# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Shared helpers for Sidekiq perform_* methods.
      module PerformMethods
        PERFORM_METHODS = %i[perform_async perform_in perform_at perform_bulk].freeze

        private

        def perform_method?(node)
          PERFORM_METHODS.include?(node.method_name)
        end
      end
    end
  end
end
