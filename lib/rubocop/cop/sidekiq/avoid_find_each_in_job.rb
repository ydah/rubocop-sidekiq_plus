# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for find_each/find_in_batches usage inside Sidekiq job perform methods.
      #
      # @example
      #   # bad
      #   class ProcessAllUsersJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       User.find_each { |user| process(user) }
      #     end
      #   end
      #
      #   # good
      #   class ProcessUserJob
      #     include Sidekiq::Job
      #
      #     def perform(user_id)
      #       user = User.find(user_id)
      #       process(user)
      #     end
      #   end
      #
      class AvoidFindEachInJob < Base
        MSG = 'Avoid processing large datasets in a single Sidekiq job. Split into smaller jobs instead.'

        DEFAULT_ALLOWED_METHODS = [].freeze
        RESTRICT_ON_SEND = %i[find_each find_in_batches].freeze

        def on_send(node)
          return unless in_sidekiq_job?(node)
          return unless in_perform_method?(node)
          return if allowed_method?(node)

          add_offense(node)
        end
        alias on_csend on_send

        private

        def in_perform_method?(node)
          node.each_ancestor(:any_def).any? do |def_node|
            def_node.method?(:perform)
          end
        end

        def allowed_method?(node)
          allowed_methods = cop_config.fetch('AllowedMethods', DEFAULT_ALLOWED_METHODS)
          allowed_methods.include?(node.method_name.to_s)
        end
      end
    end
  end
end
