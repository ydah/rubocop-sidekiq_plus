# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for deprecated Sidekiq.default_worker_options usage.
      #
      # @example
      #   # bad
      #   Sidekiq.default_worker_options = { retry: 5 }
      #
      #   # good
      #   Sidekiq.default_job_options = { retry: 5 }
      #
      class DeprecatedDefaultWorkerOptions < Base
        extend AutoCorrector

        MSG = 'Sidekiq.default_worker_options is deprecated. Use Sidekiq.default_job_options instead.'

        RESTRICT_ON_SEND = %i[default_worker_options default_worker_options=].freeze

        def on_send(node)
          return unless sidekiq_receiver?(node)

          add_offense(node.loc.selector) do |corrector|
            corrector.replace(node.loc.selector, replacement_selector(node))
          end
        end
        alias on_csend on_send

        private

        def sidekiq_receiver?(node)
          receiver = node.receiver
          receiver&.const_type? && receiver.const_name == 'Sidekiq'
        end

        def replacement_selector(_node)
          'default_job_options'
        end
      end
    end
  end
end
