# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for sensitive data passed as Sidekiq job arguments.
      #
      # @example
      #   # bad
      #   UserJob.perform_async(user_id, password)
      #
      #   # good
      #   UserJob.perform_async(user_id)
      #
      class SensitiveDataInArguments < Base
        include ArgumentTraversal

        MSG = 'Avoid passing sensitive data in Sidekiq job arguments.'

        DEFAULT_PATTERNS = %w[
          password passwd pwd token api_key secret credit_card card_number cvv ssn
        ].freeze

        RESTRICT_ON_SEND = PerformMethods.all

        def on_send(node)
          perform_call?(node) do
            check_arguments(node.arguments, allow_literal: true)
          end
        end
        alias on_csend on_send

        private

        def check_argument(arg, allow_literal:)
          return check_literal(arg, allow_literal) if literal_node?(arg)
          return check_variable(arg) if var_node?(arg)
          return check_send(arg) if arg.send_type?
          return check_hash(arg) if arg.hash_type?

          check_array_elements(arg, allow_literal: allow_literal) if arg.array_type?
        end

        def literal_node?(arg)
          arg.type?(:sym, :str)
        end

        def var_node?(arg)
          %i[lvar ivar gvar cvar].include?(arg.type)
        end

        def check_literal(arg, allow_literal)
          return unless allow_literal
          return unless sensitive_name?(arg.value.to_s)

          add_offense(arg)
        end

        def check_variable(arg)
          add_offense(arg) if sensitive_name?(arg.name.to_s)
        end

        def check_send(arg)
          return unless arg.receiver.nil? && arg.arguments.empty?
          return unless sensitive_name?(arg.method_name.to_s)

          add_offense(arg)
        end

        def check_hash(arg)
          arg.pairs.each do |pair|
            check_hash_pair(pair)
          end
        end

        def check_hash_pair(pair)
          key = pair.key
          add_offense(key) if key&.type?(:sym, :str) && sensitive_name?(key.value.to_s)
          check_argument(pair.value, allow_literal: false) if pair.value
        end

        def sensitive_name?(name)
          patterns.any? { |pattern| name.downcase.include?(pattern) }
        end

        def patterns
          Array(cop_config.fetch('SensitivePatterns', DEFAULT_PATTERNS))
        end
      end
    end
  end
end
