# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Enforces consistent job class name suffix (Job or Worker).
      #
      # @example EnforcedSuffix: Job (default)
      #   # bad
      #   class ProcessPaymentWorker
      #     include Sidekiq::Job
      #   end
      #
      #   # good
      #   class ProcessPaymentJob
      #     include Sidekiq::Job
      #   end
      #
      class ConsistentJobSuffix < Base
        MSG = 'Use `%<suffix>s` suffix for Sidekiq job class names.'

        def on_class(node)
          return unless sidekiq_job_class?(node)

          class_name = class_name(node)
          return unless class_name

          suffix = enforced_suffix
          return if class_name.end_with?(suffix)

          add_offense(node.loc.keyword, message: format(MSG, suffix: suffix))
        end

        private

        def enforced_suffix
          cop_config.fetch('EnforcedSuffix', 'Job')
        end

        def class_name(node)
          identifier = node.identifier
          return unless identifier&.const_type?

          identifier.const_name.split('::').last
        end
      end
    end
  end
end
