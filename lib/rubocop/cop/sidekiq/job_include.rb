# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks that Sidekiq jobs include the preferred module.
      #
      # Sidekiq::Worker was renamed to Sidekiq::Job in Sidekiq 6.3.
      # Sidekiq::Job is the preferred module name.
      #
      # @example PreferredModule: Job (default)
      #   # bad
      #   class MyJob
      #     include Sidekiq::Worker
      #   end
      #
      #   # good
      #   class MyJob
      #     include Sidekiq::Job
      #   end
      #
      # @example PreferredModule: Worker
      #   # bad
      #   class MyJob
      #     include Sidekiq::Job
      #   end
      #
      #   # good
      #   class MyJob
      #     include Sidekiq::Worker
      #   end
      #
      class JobInclude < Base
        extend AutoCorrector

        MSG = 'Use `Sidekiq::%<preferred>s` instead of `Sidekiq::%<deprecated>s`.'

        MODULES = %w[Job Worker].freeze

        # @!method sidekiq_include(node)
        def_node_matcher :sidekiq_include, <<~PATTERN
          (send nil? :include (const (const {nil? cbase} :Sidekiq) ${:Job :Worker}))
        PATTERN

        def on_send(node)
          sidekiq_include(node) do |module_name|
            return if module_name.to_s == preferred_module

            deprecated = module_name.to_s
            message = format(MSG, preferred: preferred_module, deprecated: deprecated)

            add_offense(node, message: message) do |corrector|
              corrector.replace(node, "include Sidekiq::#{preferred_module}")
            end
          end
        end
        alias on_csend on_send

        private

        def preferred_module
          cop_config.fetch('PreferredModule', 'Job')
        end
      end
    end
  end
end
