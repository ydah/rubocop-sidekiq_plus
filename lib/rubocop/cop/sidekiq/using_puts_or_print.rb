# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for puts/print usage inside Sidekiq jobs.
      #
      # @example
      #   # bad
      #   puts 'Processing...'
      #
      #   # good
      #   logger.info 'Processing...'
      #
      class UsingPutsOrPrint < Base
        MSG = 'Use logger instead of puts/print in Sidekiq jobs.'

        RESTRICT_ON_SEND = %i[puts print].freeze

        def on_send(node)
          return unless node.receiver.nil?
          return unless in_perform_in_sidekiq_job?(node)

          add_offense(node)
        end

        private

        def in_perform_in_sidekiq_job?(node)
          node.each_ancestor(:def).any? { |def_node| def_node.method_name == :perform } &&
            in_sidekiq_job?(node)
        end
      end
    end
  end
end
