# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that unique jobs specify the unique_for option.
      #
      # Sidekiq Enterprise unique jobs require a TTL (unique_for) to be specified.
      # Without it, uniqueness locks may persist indefinitely if jobs fail.
      #
      # @example
      #   # bad - unique_until without unique_for
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options unique_until: :start
      #   end
      #
      #   # good - both unique_for and unique_until specified
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options unique_for: 1.hour, unique_until: :start
      #   end
      #
      class UniqueJobWithoutTTL < Base
        MSG = 'Specify `unique_for` option when using unique jobs.'

        def_node_matcher :sidekiq_options_with_unique?, <<~PATTERN
          (send nil? :sidekiq_options (hash $...))
        PATTERN

        def on_send(node)
          sidekiq_options_with_unique?(node) do |pairs|
            has_unique_until = pairs.any? { |pair| option_key?(pair, :unique_until) }
            has_unique_for = pairs.any? { |pair| option_key?(pair, :unique_for) }

            add_offense(node) if has_unique_until && !has_unique_for
          end
        end

        private

        def option_key?(pair, key)
          return false unless pair.pair_type?

          pair.key.sym_type? && pair.key.value == key
        end
      end
    end
  end
end
