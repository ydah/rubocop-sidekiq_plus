# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks that batch callback methods are named correctly.
      #
      # Sidekiq Pro batch callbacks require specific method names:
      # - `:complete` callback requires `on_complete` method
      # - `:success` callback requires `on_success` method
      # - `:death` callback requires `on_death` method
      #
      # @example
      #   # bad - callback method name is incorrect
      #   class MyCallback
      #     def complete(status, options)
      #     end
      #   end
      #   batch.on(:complete, MyCallback)
      #
      #   # good
      #   class MyCallback
      #     def on_complete(status, options)
      #     end
      #   end
      #   batch.on(:complete, MyCallback)
      #
      #   # good - method specified as string
      #   batch.on(:complete, 'MyCallback#handle_complete')
      #
      class BatchCallbackMethod < Base
        CALLBACK_METHODS = {
          complete: :on_complete,
          success: :on_success,
          death: :on_death
        }.freeze

        MSG = 'Batch callback method should be named `%<expected>s`, not `%<actual>s`.'

        def on_def(node)
          return unless potential_callback_method?(node)

          method_name = node.method_name
          expected_name = expected_method_name_for(method_name)
          return unless expected_name

          add_offense(node.loc.name, message: format(MSG, expected: expected_name, actual: method_name))
        end

        private

        def potential_callback_method?(node)
          CALLBACK_METHODS.keys.include?(node.method_name) && callback_like_signature?(node)
        end

        def callback_like_signature?(node)
          node.arguments.size == 2
        end

        def expected_method_name_for(method_name)
          CALLBACK_METHODS[method_name]
        end
      end
    end
  end
end
