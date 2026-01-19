# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for Sidekiq::Worker usage and recommends Sidekiq::Job.
      #
      # @example
      #   # bad
      #   class MyWorker
      #     include Sidekiq::Worker
      #   end
      #
      #   # good
      #   class MyJob
      #     include Sidekiq::Job
      #   end
      #
      class DeprecatedWorkerModule < Base
        extend AutoCorrector

        MSG = 'Sidekiq::Worker is deprecated. Use Sidekiq::Job instead.'

        def_node_matcher :sidekiq_worker_include?, <<~PATTERN
          (send nil? :include (const (const {nil? cbase} :Sidekiq) :Worker))
        PATTERN

        def on_send(node)
          sidekiq_worker_include?(node) do
            add_offense(node) do |corrector|
              corrector.replace(node, 'include Sidekiq::Job')
            end
          end
        end
      end
    end
  end
end
