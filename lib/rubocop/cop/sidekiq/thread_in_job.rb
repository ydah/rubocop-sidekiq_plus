# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for thread creation inside Sidekiq jobs.
      #
      # Creating threads inside Sidekiq jobs is problematic because:
      # - Sidekiq already manages its own thread pool
      # - Threads may not complete before the job finishes
      # - It can lead to resource leaks and unexpected behavior
      #
      # @example
      #   # bad
      #   class MyJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       Thread.new { do_work }
      #     end
      #   end
      #
      #   # good - use separate jobs instead
      #   class MyJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       SubJob.perform_async
      #     end
      #   end
      #
      class ThreadInJob < Base
        MSG = 'Do not create threads inside Sidekiq jobs. ' \
              "Use separate jobs or Sidekiq's built-in concurrency instead."

        RESTRICT_ON_SEND = %i[new fork].freeze

        # @!method thread_creation?(node)
        def_node_matcher :thread_creation?, <<~PATTERN
          (send (const {nil? cbase} :Thread) {:new :fork} ...)
        PATTERN

        def on_send(node)
          return unless thread_creation?(node)
          return unless in_sidekiq_job?(node)

          add_offense(node)
        end
        alias on_csend on_send
      end
    end
  end
end
