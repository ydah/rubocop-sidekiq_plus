# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for symbol arguments passed to Sidekiq job methods.
      #
      # Symbols cannot be properly serialized to JSON and will be converted
      # to strings. This can lead to unexpected behavior.
      #
      # @example
      #   # bad
      #   MyJob.perform_async(:status)
      #   MyJob.perform_async(key: :value)
      #   MyJob.perform_in(1.hour, :pending)
      #
      #   # good
      #   MyJob.perform_async('status')
      #   MyJob.perform_async(key: 'value')
      #   MyJob.perform_in(1.hour, 'pending')
      #
      class SymbolArgument < Base
        extend AutoCorrector
        include ArgumentTraversal

        MSG = 'Do not pass symbols to Sidekiq jobs. Use strings instead.'

        RESTRICT_ON_SEND = PerformMethods.all

        def_node_matcher :sidekiq_perform_call?, <<~PATTERN
          (send _ {#{RESTRICT_ON_SEND.map(&:inspect).join(' ')}} $...)
        PATTERN

        def on_send(node)
          sidekiq_perform_call?(node) do |args|
            check_arguments(args)
          end
        end

        private

        def check_argument(arg)
          case arg.type
          when :sym
            register_symbol_offense(arg)
          when :dsym
            add_offense(arg)
          when :hash
            check_hash_values(arg)
          when :array
            check_array_elements(arg)
          end
        end

        def register_symbol_offense(node)
          add_offense(node) do |corrector|
            corrector.replace(node, symbol_to_string(node))
          end
        end

        def symbol_to_string(node)
          node.value.to_s.inspect
        end
      end
    end
  end
end
