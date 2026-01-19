# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for `sleep` calls inside Sidekiq jobs.
      #
      # Using `sleep` in a Sidekiq job blocks the worker thread and prevents
      # it from processing other jobs. Instead, use `perform_in` or
      # `perform_at` to schedule the job for later.
      #
      # @example
      #   # bad
      #   class MyJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       sleep 5
      #     end
      #   end
      #
      #   # good - use perform_in instead
      #   MyJob.perform_in(5.seconds, args)
      #
      class SleepInJob < Base
        MSG = 'Do not use `sleep` in Sidekiq jobs. ' \
              'It blocks the worker thread. Use `perform_in` or `perform_at` instead.'

        RESTRICT_ON_SEND = %i[sleep].freeze

        def_node_matcher :sleep_call?, <<~PATTERN
          (send {nil? (const {nil? cbase} :Kernel)} :sleep ...)
        PATTERN

        def on_send(node)
          return unless sleep_call?(node)
          return unless in_sidekiq_job?(node)

          add_offense(node)
        end
      end
    end
  end
end
