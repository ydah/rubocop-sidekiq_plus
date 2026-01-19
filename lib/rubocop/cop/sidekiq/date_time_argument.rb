# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for Date/Time/DateTime objects passed to Sidekiq job methods.
      #
      # Date and Time objects should be converted to strings or timestamps
      # before being passed to Sidekiq jobs to ensure proper serialization.
      #
      # @example
      #   # bad
      #   MyJob.perform_async(Time.current)
      #   MyJob.perform_async(Date.today)
      #   MyJob.perform_async(DateTime.now)
      #
      #   # good
      #   MyJob.perform_async(Time.current.iso8601)
      #   MyJob.perform_async(Date.today.to_s)
      #   MyJob.perform_async(Time.current.to_i)
      #
      class DateTimeArgument < Base
        MSG = 'Do not pass Date/Time objects to Sidekiq jobs. ' \
              'Convert to a string or timestamp first.'

        PERFORM_METHODS = %i[perform_async perform_in perform_at perform_bulk].freeze

        RESTRICT_ON_SEND = PERFORM_METHODS

        TIME_METHODS = %i[now current zone].freeze
        DATE_METHODS = %i[today yesterday tomorrow current].freeze

        def_node_matcher :sidekiq_perform_call?, <<~PATTERN
          (send _ {#{PERFORM_METHODS.map(&:inspect).join(' ')}} $...)
        PATTERN

        def_node_matcher :time_constructor?, <<~PATTERN
          (send (const {nil? cbase} :Time) {#{TIME_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def_node_matcher :date_constructor?, <<~PATTERN
          (send (const {nil? cbase} :Date) {#{DATE_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def_node_matcher :datetime_constructor?, <<~PATTERN
          (send (const {nil? cbase} :DateTime) {:now :current :parse} ...)
        PATTERN

        def on_send(node)
          sidekiq_perform_call?(node) do |args|
            check_arguments(args)
          end
        end

        private

        def check_arguments(args)
          args.each do |arg|
            check_argument(arg)
          end
        end

        def check_argument(arg)
          if datetime_object?(arg)
            add_offense(arg)
          elsif arg.hash_type?
            check_hash_values(arg)
          elsif arg.array_type?
            check_array_elements(arg)
          end
        end

        def datetime_object?(node)
          return false unless node.send_type?

          time_constructor?(node) || date_constructor?(node) || datetime_constructor?(node)
        end

        def check_hash_values(hash_node)
          hash_node.each_pair do |_key, value|
            check_argument(value)
          end
        end

        def check_array_elements(array_node)
          array_node.each_child_node do |element|
            check_argument(element)
          end
        end
      end
    end
  end
end
