# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that rate limiters specify wait_timeout option.
      #
      # Without wait_timeout, jobs will wait indefinitely for a limit slot,
      # potentially blocking Sidekiq worker threads. Setting wait_timeout: 0
      # for class constant limiters makes the job fail fast and rely on retry.
      #
      # @example
      #   # bad - no wait_timeout specified
      #   API_LIMITER = Sidekiq::Limiter.concurrent('api', 50)
      #
      #   # good - explicit wait_timeout
      #   API_LIMITER = Sidekiq::Limiter.concurrent('api', 50, wait_timeout: 0)
      #
      #   # good - wait_timeout with value
      #   API_LIMITER = Sidekiq::Limiter.concurrent('api', 50, wait_timeout: 5)
      #
      class LimiterWithoutWaitTimeout < Base
        MSG = 'Specify `wait_timeout` option for rate limiters to avoid blocking worker threads.'

        def on_send(node)
          limiter_creation?(node) do |_method, _name, _limit|
            return if wait_timeout_option?(node)

            add_offense(node)
          end
        end
        alias on_csend on_send

        private

        def wait_timeout_option?(node)
          options_hash = find_options_hash(node)
          return false unless options_hash

          options_hash.pairs.any? { |pair| pair.key.value == :wait_timeout }
        end

        def find_options_hash(node)
          node.arguments.find(&:hash_type?)
        end
      end
    end
  end
end
