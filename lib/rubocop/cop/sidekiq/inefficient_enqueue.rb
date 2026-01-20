# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for perform_async calls inside loops and recommends perform_bulk.
      #
      # @example
      #   # bad
      #   users.each do |user|
      #     NotifyJob.perform_async(user.id)
      #   end
      #
      #   # good
      #   user_ids = users.map { |user| [user.id] }
      #   NotifyJob.perform_bulk(user_ids)
      #
      class InefficientEnqueue < Base
        MSG = 'Prefer `perform_bulk` over `perform_async` inside loops to reduce Redis round trips.'

        DEFAULT_ALLOWED_METHODS = %w[each find_each find_in_batches].freeze

        def on_block(node)
          send_node = node.send_node
          return unless allowed_method?(send_node)
          return unless meets_minimum_iterations?(send_node)

          check_send(node.body)
        end

        def on_numblock(node)
          on_block(node)
        end

        private

        def check_send(body_node)
          return unless body_node

          add_offense(body_node) if body_node.send_type? && body_node.method?(:perform_async)

          body_node.each_descendant(:send) do |send|
            next unless send.method?(:perform_async)

            add_offense(send)
          end
        end

        def allowed_method?(send_node)
          allowed_methods = cop_config.fetch('AllowedMethods', DEFAULT_ALLOWED_METHODS)
          allowed_methods.include?(send_node.method_name.to_s)
        end

        def meets_minimum_iterations?(send_node)
          minimum = cop_config['MinimumIterations']
          return true unless minimum

          iteration_count = iteration_count(send_node)
          return true unless iteration_count

          iteration_count >= minimum
        end

        def iteration_count(send_node)
          return unless send_node.method?(:times)

          receiver = send_node.receiver
          return unless receiver&.int_type?

          receiver.value
        end
      end
    end
  end
end
