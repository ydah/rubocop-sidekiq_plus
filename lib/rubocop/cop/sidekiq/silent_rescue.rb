# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for rescue blocks that swallow exceptions in Sidekiq jobs.
      #
      # @example
      #   # bad
      #   def perform
      #     do_work
      #   rescue => e
      #     Rails.logger.error(e)
      #   end
      #
      #   # good
      #   def perform
      #     do_work
      #   rescue => e
      #     Rails.logger.error(e)
      #     raise
      #   end
      #
      class SilentRescue < Base
        MSG = 'Do not silently swallow exceptions in Sidekiq jobs. Re-raise or handle explicitly.'
        RERAISE_METHODS = %i[raise fail].freeze

        def on_def(node)
          return unless node.method?(:perform)
          return unless in_sidekiq_job?(node)

          node.each_descendant(:resbody) do |resbody|
            next if allowed_exception?(resbody)
            next if re_raises?(resbody)

            add_offense(resbody)
          end
        end

        private

        def allowed_exception?(resbody)
          allowed = Array(cop_config.fetch('AllowedExceptions', []))
          exceptions = resbody.exceptions
          return false if exceptions.nil? || exceptions.empty?

          exceptions.all? do |exception|
            exception.const_type? && allowed.include?(exception.const_name)
          end
        end

        def re_raises?(resbody)
          body = resbody.body
          return false unless body

          body.each_descendant(:send).any? do |send|
            send.receiver.nil? && RERAISE_METHODS.include?(send.method_name)
          end
        end
      end
    end
  end
end
