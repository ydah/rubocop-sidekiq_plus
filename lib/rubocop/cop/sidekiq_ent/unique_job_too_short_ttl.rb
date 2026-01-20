# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that unique jobs have sufficient TTL.
      #
      # A too short unique_for TTL may expire during retries, allowing
      # duplicate jobs to be enqueued while the original is still retrying.
      #
      # @example
      #   # bad - TTL too short
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options unique_for: 30
      #   end
      #
      #   # good - adequate TTL
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options unique_for: 3600
      #   end
      #
      class UniqueJobTooShortTTL < Base
        MSG = 'Unique job TTL is too short (minimum: %<minimum>s seconds). ' \
              'Consider increasing `unique_for` to cover retry period.'

        MINIMUM_TTL = 60

        def_node_matcher :unique_for_value, <<~PATTERN
          (send nil? :sidekiq_options (hash <(pair (sym :unique_for) $_) ...>))
        PATTERN

        def on_send(node)
          unique_for_value(node) do |value_node|
            ttl = extract_seconds(value_node)
            return unless ttl && ttl < minimum_ttl

            add_offense(value_node, message: format(MSG, minimum: minimum_ttl))
          end
        end

        private

        def minimum_ttl
          cop_config.fetch('MinimumTTL', MINIMUM_TTL)
        end

        def extract_seconds(node)
          case node.type
          when :int
            node.value
          when :float
            node.value.to_i
          when :send
            extract_duration_seconds(node)
          end
        end

        def extract_duration_seconds(node)
          return unless node.receiver&.int_type? || node.receiver&.float_type?

          value = node.receiver.value.to_f
          duration_multiplier(node.method_name, value)&.to_i
        end

        def duration_multiplier(method_name, value)
          case method_name
          when :seconds, :second then value
          when :minutes, :minute then value * 60
          when :hours, :hour then value * 3600
          when :days, :day then value * 86_400
          end
        end
      end
    end
  end
end
