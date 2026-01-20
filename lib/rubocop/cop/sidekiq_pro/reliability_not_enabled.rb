# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqPro
      # Checks that Sidekiq Pro reliability features are enabled.
      #
      # Sidekiq Pro provides `super_fetch!` and `reliable_push!` for
      # improved job reliability. These should be enabled in production.
      #
      # @example
      #   # bad - reliability features not enabled
      #   Sidekiq.configure_server do |config|
      #     config.redis = { url: ENV['REDIS_URL'] }
      #   end
      #
      #   # good - reliability features enabled
      #   Sidekiq.configure_server do |config|
      #     config.redis = { url: ENV['REDIS_URL'] }
      #     config.super_fetch!
      #     config.reliable_push!
      #   end
      #
      class ReliabilityNotEnabled < Base
        MSG_SUPER_FETCH = 'Consider enabling `super_fetch!` for reliable job fetching.'
        MSG_RELIABLE_PUSH = 'Consider enabling `reliable_push!` for reliable job pushing.'

        # @!method configure_server_block?(node)
        def_node_matcher :configure_server_block?, <<~PATTERN
          (block
            (send (const {nil? cbase} :Sidekiq) :configure_server)
            (args (arg $_))
            $_
          )
        PATTERN

        def on_block(node)
          configure_server_block?(node) do |config_var, body|
            return unless body

            check_reliability_features(node, config_var, body)
          end
        end
        alias on_numblock on_block

        private

        def check_reliability_features(node, config_var, body)
          has_super_fetch = method_call?(body, config_var, :super_fetch!)
          has_reliable_push = method_call?(body, config_var, :reliable_push!)

          add_offense(node.send_node, message: MSG_SUPER_FETCH) unless has_super_fetch
          add_offense(node.send_node, message: MSG_RELIABLE_PUSH) unless has_reliable_push
        end

        def method_call?(body, config_var, method_name)
          nodes_to_check = body.send_type? ? [body] : body.each_descendant(:send).to_a
          nodes_to_check.any? do |send_node|
            send_node.method?(method_name) &&
              send_node.receiver&.lvar_type? &&
              send_node.receiver.children.first == config_var
          end
        end
      end
    end
  end
end
