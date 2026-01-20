# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for missing logging in Sidekiq job perform methods.
      #
      # @example
      #   # bad
      #   def perform(user_id)
      #     do_work(user_id)
      #   end
      #
      #   # good
      #   def perform(user_id)
      #     logger.info "Starting job for #{user_id}"
      #     do_work(user_id)
      #   end
      #
      class MissingLogging < Base
        MSG = 'Add logging to Sidekiq job perform methods.'

        def on_def(node)
          return unless node.method?(:perform)
          return unless in_sidekiq_job?(node)
          return if logger_call?(node)

          add_offense(node.loc.keyword)
        end

        private

        def logger_call?(def_node)
          def_node.each_descendant(:send).any? { |send| logger_call_send?(send) }
        end

        def logger_call_send?(send)
          receiver = send.receiver
          return false unless receiver&.send_type?

          receiver_name = receiver.method_name
          return false unless %i[logger].include?(receiver_name)

          %i[debug info warn error fatal].include?(send.method_name)
        end
      end
    end
  end
end
