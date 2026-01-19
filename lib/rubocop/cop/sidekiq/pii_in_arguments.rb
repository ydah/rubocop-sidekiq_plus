# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for PII passed as Sidekiq job arguments.
      #
      # @example
      #   # bad
      #   NotifyJob.perform_async(email: 'user@example.com')
      #
      #   # good
      #   NotifyJob.perform_async(user_id)
      #
      class PiiInArguments < Base
        MSG = 'Avoid passing PII in Sidekiq job arguments.'

        DEFAULT_PATTERNS = %w[email phone address].freeze

        RESTRICT_ON_SEND = %i[perform_async perform_in perform_at perform_bulk].freeze

        def on_send(node)
          perform_call?(node) do
            node.arguments.each { |arg| check_argument(arg, allow_literal: true) }
          end
        end

        private

        def check_argument(arg, allow_literal:)
          return check_literal(arg, allow_literal) if literal_node?(arg)
          return check_variable(arg) if var_node?(arg)
          return check_send(arg) if arg.send_type?
          return check_hash(arg) if arg.hash_type?

          check_array(arg, allow_literal) if arg.array_type?
        end

        def literal_node?(arg)
          arg.sym_type? || arg.str_type?
        end

        def var_node?(arg)
          %i[lvar ivar gvar cvar].include?(arg.type)
        end

        def check_literal(arg, allow_literal)
          return unless allow_literal
          return unless pii_name?(arg.value.to_s)

          add_offense(arg)
        end

        def check_variable(arg)
          add_offense(arg) if pii_name?(arg.name.to_s)
        end

        def check_send(arg)
          return unless arg.receiver.nil? && arg.arguments.empty?
          return unless pii_name?(arg.method_name.to_s)

          add_offense(arg)
        end

        def check_hash(arg)
          arg.pairs.each do |pair|
            check_hash_pair(pair)
          end
        end

        def check_hash_pair(pair)
          key = pair.key
          add_offense(key) if key && (key.sym_type? || key.str_type?) && pii_name?(key.value.to_s)
          check_argument(pair.value, allow_literal: false) if pair.value
        end

        def check_array(arg, allow_literal)
          arg.each_value { |value| check_argument(value, allow_literal: allow_literal) }
        end

        def pii_name?(name)
          patterns.any? { |pattern| name.downcase.include?(pattern) }
        end

        def patterns
          Array(cop_config.fetch('PiiPatterns', DEFAULT_PATTERNS))
        end
      end
    end
  end
end
