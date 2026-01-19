# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for jobs that reschedule themselves.
      #
      # @example
      #   # bad
      #   def perform
      #     self.class.perform_in(1.hour)
      #   end
      #
      class SelfSchedulingJob < Base
        MSG = 'Avoid self-scheduling jobs. Use Sidekiq Cron or scheduler instead.'

        RESTRICT_ON_SEND = %i[perform_async perform_in perform_at].freeze

        def on_def(node)
          return unless node.method_name == :perform
          return unless in_sidekiq_job?(node)

          class_node = node.each_ancestor(:class).first
          class_name = class_name(class_node)

          node.each_descendant(:send) do |send|
            next unless RESTRICT_ON_SEND.include?(send.method_name)
            next unless self_receiver?(send.receiver, class_name)

            add_offense(send)
          end
        end

        private

        def class_name(class_node)
          identifier = class_node&.identifier
          return unless identifier&.const_type?

          identifier.const_name.split('::').last
        end

        def self_receiver?(receiver, class_name)
          return false unless receiver

          self_class_receiver?(receiver) || const_self_receiver?(receiver, class_name)
        end

        def self_class_receiver?(receiver)
          receiver.send_type? &&
            receiver.method_name == :class &&
            receiver.receiver&.self_type?
        end

        def const_self_receiver?(receiver, class_name)
          receiver.const_type? && class_name && receiver.const_name.split('::').last == class_name
        end
      end
    end
  end
end
