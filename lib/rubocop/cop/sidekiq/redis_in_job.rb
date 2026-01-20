# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for direct Redis connections inside Sidekiq jobs.
      #
      # @example
      #   # bad
      #   redis = Redis.new
      #
      #   # good
      #   Sidekiq.redis { |conn| conn.get('key') }
      #
      class RedisInJob < Base
        MSG = 'Use Sidekiq.redis instead of creating a new Redis connection in jobs.'

        def on_def(node)
          return unless node.method?(:perform)
          return unless in_sidekiq_job?(node)

          node.each_descendant(:send) do |send|
            receiver = send.receiver
            next unless receiver&.const_name == 'Redis' && send.method?(:new)

            add_offense(send)
          end
        end
      end
    end
  end
end
