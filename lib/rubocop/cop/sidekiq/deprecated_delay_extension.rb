# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for deprecated delay extension usage.
      #
      # @example
      #   # bad
      #   UserMailer.delay.welcome_email(user)
      #
      #   # good
      #   UserMailer.welcome_email(user).deliver_later
      #
      class DeprecatedDelayExtension < Base
        MSG = 'Avoid using the delay extension. Use `deliver_later` or enqueue a Sidekiq job instead.'

        RESTRICT_ON_SEND = %i[delay].freeze

        def on_send(node)
          return unless node.arguments.empty?

          add_offense(node.loc.selector)
        end
        alias on_csend on_send
      end
    end
  end
end
