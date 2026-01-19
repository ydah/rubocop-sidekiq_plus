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

        MSG = 'Do not pass symbols to Sidekiq jobs. Use strings instead.'

        PERFORM_METHODS = %i[perform_async perform_in perform_at perform_bulk].freeze

        RESTRICT_ON_SEND = PERFORM_METHODS

        def_node_matcher :sidekiq_perform_call?, <<~PATTERN
          (send _ {#{PERFORM_METHODS.map(&:inspect).join(' ')}} $...)
        PATTERN

        def on_send(node)
          sidekiq_perform_call?(node) do |args|
            check_arguments(args)
          end
        end

        private

        def check_arguments(args)
          args.each do |arg|
            check_argument(arg)
          end
        end

        def check_argument(arg)
          case arg.type
          when :sym
            register_symbol_offense(arg)
          when :hash
            check_hash_values(arg)
          when :array
            check_array_elements(arg)
          end
        end

        def check_hash_values(hash_node)
          hash_node.each_pair do |_key, value|
            check_argument(value)
          end
        end

        def check_array_elements(array_node)
          array_node.each_child_node do |element|
            check_argument(element)
          end
        end

        def register_symbol_offense(node)
          add_offense(node) do |corrector|
            corrector.replace(node, symbol_to_string(node))
          end
        end

        def symbol_to_string(node)
          "'#{node.value}'"
        end
      end
    end
  end
end
