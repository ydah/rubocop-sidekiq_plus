# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that rate limiters are created as class constants for reuse.
      #
      # Creating limiters inside the perform method causes Redis memory leaks
      # because each instance creates new Redis keys. Limiters should be
      # defined as class constants to be reused across job executions.
      #
      # @example
      #   # bad - limiter created inside perform
      #   class MyJob
      #     include Sidekiq::Job
      #
      #     def perform
      #       limiter = Sidekiq::Limiter.concurrent('api', 50)
      #       limiter.within_limit { call_api }
      #     end
      #   end
      #
      #   # good - limiter as class constant
      #   class MyJob
      #     include Sidekiq::Job
      #     API_LIMITER = Sidekiq::Limiter.concurrent('api', 50, wait_timeout: 0)
      #
      #     def perform
      #       API_LIMITER.within_limit { call_api }
      #     end
      #   end
      #
      #   # good - dynamic limiter name (user-specific)
      #   class MyJob
      #     include Sidekiq::Job
      #
      #     def perform(user_id)
      #       limiter = Sidekiq::Limiter.concurrent("api-#{user_id}", 10)
      #       limiter.within_limit { call_api_for_user(user_id) }
      #     end
      #   end
      #
      class LimiterNotReused < Base
        MSG = 'Create rate limiters as class constants for reuse.'

        def on_send(node)
          limiter_creation?(node) do |_method, name, _limit|
            return if inside_class_body_directly?(node)
            return if dynamic_limiter_name?(name)

            add_offense(node)
          end
        end
        alias on_csend on_send

        private

        def inside_class_body_directly?(node)
          !inside_method?(node) && inside_class?(node)
        end

        def inside_method?(node)
          node.each_ancestor(:any_def).any?
        end

        def inside_class?(node)
          node.each_ancestor(:class).any?
        end

        def dynamic_limiter_name?(name)
          return true if name.dstr_type?
          return true if name.send_type?

          false
        end
      end
    end
  end
end
