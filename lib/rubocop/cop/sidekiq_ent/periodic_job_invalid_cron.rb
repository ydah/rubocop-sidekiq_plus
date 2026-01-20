# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that cron expressions in periodic job registration are valid.
      #
      # Invalid cron expressions will cause Sidekiq Enterprise to fail when
      # loading the periodic job configuration.
      #
      # @example
      #   # bad - invalid cron (6 fields)
      #   config.periodic do |mgr|
      #     mgr.register('0 * * * * *', 'SomeJob')
      #   end
      #
      #   # bad - invalid minute value
      #   config.periodic do |mgr|
      #     mgr.register('60 * * * *', 'SomeJob')
      #   end
      #
      #   # good - valid cron
      #   config.periodic do |mgr|
      #     mgr.register('0 * * * *', 'SomeJob')
      #   end
      #
      class PeriodicJobInvalidCron < Base
        MSG = 'Invalid cron expression: %<reason>s'

        def_node_matcher :periodic_register?, <<~PATTERN
          (send _ :register (str $_) ...)
        PATTERN

        def on_send(node)
          periodic_register?(node) do |cron_expression|
            error = validate_cron(cron_expression)
            add_offense(node.first_argument, message: format(MSG, reason: error)) if error
          end
        end

        private

        def validate_cron(expression)
          fields = expression.strip.split(/\s+/)

          return 'expected 5 fields (minute hour day month weekday)' unless fields.size == 5

          validate_field(fields[0], 0, 59, 'minute') ||
            validate_field(fields[1], 0, 23, 'hour') ||
            validate_field(fields[2], 1, 31, 'day') ||
            validate_field(fields[3], 1, 12, 'month') ||
            validate_field(fields[4], 0, 6, 'weekday')
        end

        def validate_field(field, min, max, name)
          return nil if field == '*'

          if field.include?('/')
            step_validation(field, min, max, name)
          elsif field.include?(',')
            list_validation(field, min, max, name)
          elsif field.include?('-')
            range_validation(field, min, max, name)
          else
            value_validation(field, min, max, name)
          end
        end

        def step_validation(field, min, max, name)
          base, step = field.split('/', 2)
          base_error = base == '*' ? nil : validate_field(base, min, max, name)
          return base_error if base_error
          return "invalid step value for #{name}" unless step&.match?(/\A\d+\z/)
          return "step value out of range for #{name}" unless step.to_i.between?(1, max)

          nil
        end

        def list_validation(field, min, max, name)
          field.split(',').each do |value|
            error = validate_field(value.strip, min, max, name)
            return error if error
          end
          nil
        end

        def range_validation(field, min, max, name)
          start_val, end_val = field.split('-', 2)
          return "invalid range for #{name}" unless start_val&.match?(/\A\d+\z/) && end_val&.match?(/\A\d+\z/)

          in_range = start_val.to_i.between?(min, max) && end_val.to_i.between?(min, max)
          return "#{name} value out of range" unless in_range

          nil
        end

        def value_validation(field, min, max, name)
          return "invalid #{name} value" unless field.match?(/\A\d+\z/)
          return "#{name} value out of range (#{min}-#{max})" unless field.to_i.between?(min, max)

          nil
        end
      end
    end
  end
end
