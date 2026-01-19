# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for excessive retry counts in sidekiq_options.
      #
      # @example MaxRetries: 25 (default)
      #   # bad
      #   sidekiq_options retry: 100
      #
      class ExcessiveRetry < Base
        MSG = 'Retry count exceeds the maximum allowed (%<max>d).'

        def on_send(node)
          sidekiq_options_call?(node) do |args|
            args.each { |arg| check_hash(arg) }
          end
        end

        private

        def check_hash(arg)
          return unless arg.hash_type?

          arg.pairs.each do |pair|
            check_pair(pair)
          end
        end

        def check_pair(pair)
          return unless retry_key?(pair.key)

          value = pair.value
          return unless value&.int_type?
          return unless value.value > max_retries

          add_offense(value, message: format(MSG, max: max_retries))
        end

        def retry_key?(node)
          node&.sym_type? && node.value == :retry
        end

        def max_retries
          cop_config.fetch('MaxRetries', 25)
        end
      end
    end
  end
end
