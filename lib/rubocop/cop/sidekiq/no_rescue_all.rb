# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for bare `rescue` or `rescue Exception` in Sidekiq jobs.
      #
      # Rescuing all exceptions can hide bugs and prevent Sidekiq's retry
      # mechanism from working properly. If you need to handle errors,
      # rescue specific exception classes and consider re-raising.
      #
      # @example
      #   # bad
      #   class MyJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       do_work
      #     rescue
      #       log_error
      #     end
      #   end
      #
      #   # bad
      #   class MyJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       do_work
      #     rescue Exception
      #       log_error
      #     end
      #   end
      #
      #   # good
      #   class MyJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       do_work
      #     rescue NetworkError => e
      #       log_error(e)
      #       raise
      #     end
      #   end
      #
      class NoRescueAll < Base
        MSG = 'Avoid rescuing all exceptions in Sidekiq jobs. ' \
              'Rescue specific exceptions and consider re-raising.'

        # @!method bare_rescue?(node)
        def_node_matcher :bare_rescue?, <<~PATTERN
          (resbody nil? ...)
        PATTERN

        # @!method rescue_exception?(node)
        def_node_matcher :rescue_exception?, <<~PATTERN
          (resbody (array (const {nil? cbase} :Exception)) ...)
        PATTERN

        def on_resbody(node)
          return unless in_sidekiq_job?(node)
          return unless bare_rescue?(node) || rescue_exception?(node)

          add_offense(node)
        end
      end
    end
  end
end
