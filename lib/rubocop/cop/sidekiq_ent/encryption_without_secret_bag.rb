# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that encrypted jobs have meaningful arguments to encrypt.
      #
      # Sidekiq Enterprise encryption only encrypts the last argument.
      # If the job only has a single ID-like argument, encryption may
      # not provide much value.
      #
      # @example
      #   # questionable - only ID argument
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options encrypt: true
      #
      #     def perform(user_id)
      #     end
      #   end
      #
      #   # good - secret data in last argument
      #   class MyJob
      #     include Sidekiq::Job
      #     sidekiq_options encrypt: true
      #
      #     def perform(user_id, secret_data)
      #     end
      #   end
      #
      class EncryptionWithoutSecretBag < Base
        include RuboCop::Sidekiq::Language

        MSG = 'Encrypted job has only one argument. ' \
              'Consider if encryption is necessary or add a secret bag argument.'

        def_node_matcher :encryption_enabled?, <<~PATTERN
          (send nil? :sidekiq_options (hash <(pair (sym :encrypt) {(true) (sym :true)}) ...>))
        PATTERN

        def on_send(node)
          return unless encryption_enabled?(node)

          class_node = node.each_ancestor(:class).first
          return unless class_node

          perform_method = find_perform_method(class_node)
          return unless perform_method

          add_offense(perform_method.loc.name) if single_id_like_argument?(perform_method)
        end

        private

        def find_perform_method(class_node)
          class_node.body&.each_descendant(:def)&.find do |def_node|
            def_node.method_name == :perform
          end
        end

        def single_id_like_argument?(method_node)
          args = method_node.arguments
          return false unless args.size == 1

          arg_name = args.first.name.to_s
          id_like_patterns.any? { |pattern| arg_name.match?(pattern) }
        end

        def id_like_patterns
          @id_like_patterns ||= [
            /_id\z/,
            /\Aid\z/,
            /_ids\z/,
            /\Auuid\z/,
            /\Arecord_id\z/
          ]
        end
      end
    end
  end
end
