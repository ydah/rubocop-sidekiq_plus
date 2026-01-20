# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that unique_until option has an appropriate value.
      #
      # Using unique_until: :start may cause unexpected behavior as the lock
      # is released when the job starts, allowing concurrent execution
      # of identical jobs.
      #
      # @example
      #   # bad - lock released on start
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options unique_for: 600, unique_until: :start
      #   end
      #
      #   # good - default behavior (success)
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options unique_for: 600
      #   end
      #
      #   # good - explicit success
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options unique_for: 600, unique_until: :success
      #   end
      #
      class UniqueUntilMismatch < Base
        MSG = 'Avoid `unique_until: :%<value>s`. ' \
              'Prefer `unique_until: :success` (default) to prevent concurrent execution.'

        ALLOWED_VALUES = %i[success].freeze

        # @!method unique_until_value(node)
        def_node_matcher :unique_until_value, <<~PATTERN
          (send nil? :sidekiq_options (hash <(pair (sym :unique_until) (sym $_)) ...>))
        PATTERN

        def on_send(node)
          unique_until_value(node) do |value|
            return if allowed_values.include?(value)

            add_offense(node, message: format(MSG, value: value))
          end
        end
        alias on_csend on_send

        private

        def allowed_values
          Array(cop_config.fetch('AllowedValues', ALLOWED_VALUES)).map(&:to_sym)
        end
      end
    end
  end
end
