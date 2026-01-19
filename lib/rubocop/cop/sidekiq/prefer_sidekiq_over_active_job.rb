# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Recommends using Sidekiq::Job over ActiveJob.
      #
      # @example
      #   # bad
      #   class MyJob < ApplicationJob
      #     def perform; end
      #   end
      #
      #   # good
      #   class MyJob
      #     include Sidekiq::Job
      #   end
      #
      class PreferSidekiqOverActiveJob < Base
        MSG = 'Prefer Sidekiq::Job over ActiveJob for Sidekiq-specific features.'

        def on_class(node)
          return unless active_job_class?(node)

          add_offense(node.loc.keyword)
        end
      end
    end
  end
end
