# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks that expiring jobs have appropriate TTL values.
      #
      # A TTL that is too short may cause jobs to expire before processing,
      # while a TTL that is too long defeats the purpose of expiring jobs.
      #
      # @example
      #   # bad - TTL too short
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options expires_in: 1.minute
      #   end
      #
      #   # bad - TTL too long
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options expires_in: 30.days
      #   end
      #
      #   # good - appropriate TTL
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options expires_in: 1.hour
      #   end
      #
      class ExpiringJobWithoutTTL < Base
        MSG_TOO_SHORT = 'Expiring job TTL is too short (minimum: %<minimum>s seconds). ' \
                        'Jobs may expire before processing.'
        MSG_TOO_LONG = 'Expiring job TTL is too long (maximum: %<maximum>s seconds). ' \
                       'Consider a shorter TTL for expiring jobs.'

        MINIMUM_TTL = 300
        MAXIMUM_TTL = 604_800

        # @!method expires_in_value(node)
        def_node_matcher :expires_in_value, <<~PATTERN
          (send nil? :sidekiq_options (hash <(pair (sym :expires_in) $_) ...>))
        PATTERN

        def on_send(node)
          expires_in_value(node) do |value_node|
            ttl = extract_seconds(value_node)
            return unless ttl

            check_ttl_range(value_node, ttl)
          end
        end
        alias on_csend on_send

        private

        def check_ttl_range(node, ttl)
          if ttl < minimum_ttl
            add_offense(node, message: format(MSG_TOO_SHORT, minimum: minimum_ttl))
          elsif ttl > maximum_ttl
            add_offense(node, message: format(MSG_TOO_LONG, maximum: maximum_ttl))
          end
        end

        def minimum_ttl
          cop_config.fetch('MinimumTTL', MINIMUM_TTL)
        end

        def maximum_ttl
          cop_config.fetch('MaximumTTL', MAXIMUM_TTL)
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
          return unless node.receiver&.type?(:int, :float)

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
