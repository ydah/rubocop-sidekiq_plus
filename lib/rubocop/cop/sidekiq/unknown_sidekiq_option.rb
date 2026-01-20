# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for unknown or unsupported options passed to sidekiq_options.
      #
      # @example
      #   # bad
      #   sidekiq_options priorty: :high
      #   sidekiq_options unique: true
      #
      #   # good
      #   sidekiq_options queue: :critical, retry: 5
      #
      class UnknownSidekiqOption < Base
        MSG = 'Unknown or unsupported Sidekiq option `%<option>s` in `sidekiq_options`.'

        ALLOWED_OPTIONS = %w[queue retry dead backtrace pool tags].freeze

        def on_send(node)
          sidekiq_options_call?(node) do |args|
            args.each do |arg|
              check_options_hash(arg)
            end
          end
        end
        alias on_csend on_send

        private

        def check_options_hash(node)
          return unless node.hash_type?

          node.pairs.each do |pair|
            option = option_name(pair.key)
            next unless option
            next if ALLOWED_OPTIONS.include?(option)

            add_offense(pair, message: format(MSG, option: option))
          end
        end

        def option_name(node)
          return node.value.to_s if node.sym_type?

          node.value if node.str_type?
        end
      end
    end
  end
end
