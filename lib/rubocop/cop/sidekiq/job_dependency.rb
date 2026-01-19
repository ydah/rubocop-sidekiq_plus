# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for implicit job dependencies (enqueuing other jobs inside jobs).
      #
      # @example
      #   # bad
      #   def perform
      #     SecondJob.perform_async
      #   end
      #
      class JobDependency < Base
        MSG = 'Avoid implicit job dependencies. Use Sidekiq Batches instead.'

        def on_def(node)
          return unless node.method_name == :perform
          return unless in_sidekiq_job?(node)

          node.each_descendant(:send) do |send|
            next unless perform_call?(send)

            add_offense(send)
          end
        end
      end
    end
  end
end
