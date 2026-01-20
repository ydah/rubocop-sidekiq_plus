# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks that job class names are constants.
      #
      # Using dynamic class names for jobs can lead to:
      # - Security vulnerabilities (arbitrary code execution)
      # - Difficult to trace job execution
      # - Harder static analysis
      #
      # @example
      #   # bad
      #   job_class.perform_async(args)
      #   "#{prefix}Job".constantize.perform_async(args)
      #
      #   # good
      #   MyJob.perform_async(args)
      #   MyModule::MyJob.perform_async(args)
      #
      class ConstantJobClassName < Base
        MSG = 'Use a constant class name for Sidekiq jobs. ' \
              'Dynamic job class names are harder to trace and may be insecure.'

        RESTRICT_ON_SEND = PerformMethods.all

        def on_send(node)
          return unless RESTRICT_ON_SEND.include?(node.method_name)
          return if constant_receiver?(node)

          add_offense(node.receiver)
        end
        alias on_csend on_send

        private

        def constant_receiver?(node)
          receiver = node.receiver
          return false unless receiver

          receiver.const_type? || (receiver.send_type? && nested_const?(receiver))
        end

        def nested_const?(node)
          return true if node.const_type?

          node.send_type? && node.receiver && nested_const?(node.receiver)
        end
      end
    end
  end
end
