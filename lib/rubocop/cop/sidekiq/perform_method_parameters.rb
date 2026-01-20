# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks that the perform method does not use keyword arguments.
      #
      # Sidekiq serializes job arguments to JSON, which does not support
      # Ruby keyword arguments. Using keyword arguments will cause errors
      # or unexpected behavior.
      #
      # @example
      #   # bad
      #   def perform(user_id:, status:)
      #   end
      #
      #   # bad
      #   def perform(id, status: 'pending')
      #   end
      #
      #   # good
      #   def perform(user_id, status)
      #   end
      #
      class PerformMethodParameters < Base
        MSG = 'Do not use keyword arguments in the `perform` method. ' \
              'Sidekiq cannot serialize keyword arguments to JSON.'

        # @!method perform_method?(node)
        def_node_matcher :perform_method?, <<~PATTERN
          (def :perform ...)
        PATTERN

        def on_def(node)
          return unless perform_method?(node)
          return unless in_sidekiq_job?(node)

          node.arguments.each do |arg|
            next unless keyword_argument?(arg)

            add_offense(arg)
          end
        end

        private

        def keyword_argument?(arg)
          arg.type?(:kwarg, :kwoptarg, :kwrestarg)
        end
      end
    end
  end
end
