# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for retry: 0 usage and suggests retry: false for clarity.
      #
      # @example
      #   # bad
      #   sidekiq_options retry: 0
      #
      #   # good
      #   sidekiq_options retry: false
      #
      class RetryZero < Base
        MSG = 'Use `retry: false` instead of `retry: 0` for clarity.'

        def on_send(node)
          sidekiq_options_call?(node) do |args|
            args.each { |arg| check_hash(arg) }
          end
        end

        private

        def check_hash(arg)
          return unless arg.hash_type?

          arg.pairs.each { |pair| check_pair(pair) }
        end

        def check_pair(pair)
          return unless retry_key?(pair.key)

          value = pair.value
          return unless value&.int_type? && value.value.zero?

          add_offense(value)
        end

        def retry_key?(node)
          node&.sym_type? && node.value == :retry
        end
      end
    end
  end
end
