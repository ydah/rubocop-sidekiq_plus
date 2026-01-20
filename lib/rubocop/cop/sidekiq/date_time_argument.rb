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
        include ArgumentTraversal

        MSG = 'Do not pass Date/Time objects to Sidekiq jobs. ' \
              'Convert to a string or timestamp first.'

        RESTRICT_ON_SEND = PerformMethods.all

        TIME_METHODS = %i[now current zone].freeze
        DATE_METHODS = %i[today yesterday tomorrow current].freeze

        # @!method sidekiq_perform_call?(node)
        def_node_matcher :sidekiq_perform_call?, <<~PATTERN
          (send _ {#{RESTRICT_ON_SEND.map(&:inspect).join(' ')}} $...)
        PATTERN

        # @!method time_constructor?(node)
        def_node_matcher :time_constructor?, <<~PATTERN
          (send (const {nil? cbase} :Time) {#{TIME_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        # @!method date_constructor?(node)
        def_node_matcher :date_constructor?, <<~PATTERN
          (send (const {nil? cbase} :Date) {#{DATE_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        # @!method datetime_constructor?(node)
        def_node_matcher :datetime_constructor?, <<~PATTERN
          (send (const {nil? cbase} :DateTime) {:now :current :parse} ...)
        PATTERN

        def on_send(node)
          sidekiq_perform_call?(node) do |args|
            check_arguments(args)
          end
        end
        alias on_csend on_send

        private

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
      end
    end
  end
end
