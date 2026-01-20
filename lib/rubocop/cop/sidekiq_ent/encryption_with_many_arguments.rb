# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that encrypted jobs use proper argument structure.
      #
      # Sidekiq Enterprise encryption only encrypts the last argument.
      # If sensitive data is passed in non-last arguments, it won't be encrypted.
      #
      # @example
      #   # bad - sensitive data not in last argument
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options encrypt: true
      #
      #     def perform(password, user_id, options)
      #     end
      #   end
      #
      #   # good - sensitive data in last argument (secret bag)
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options encrypt: true
      #
      #     def perform(user_id, secret_bag)
      #     end
      #   end
      #
      class EncryptionWithManyArguments < Base
        include RuboCop::Sidekiq::Language

        MSG = 'Encrypted jobs should use a secret bag pattern. ' \
              'Only the last argument is encrypted; consider consolidating sensitive data.'

        MAX_RECOMMENDED_ARGS = 2

        def_node_matcher :encryption_enabled?, <<~PATTERN
          (send nil? :sidekiq_options (hash <(pair (sym :encrypt) {(true) (sym :true)}) ...>))
        PATTERN

        def on_send(node)
          return unless encryption_enabled?(node)

          class_node = node.each_ancestor(:class).first
          return unless class_node

          perform_method = find_perform_method(class_node)
          return unless perform_method

          arg_count = perform_method.arguments.size
          add_offense(perform_method.loc.name) if arg_count > max_args
        end

        private

        def max_args
          cop_config.fetch('MaxArguments', MAX_RECOMMENDED_ARGS)
        end

        def find_perform_method(class_node)
          class_node.body&.each_descendant(:def)&.find do |def_node|
            def_node.method_name == :perform
          end
        end
      end
    end
  end
end
