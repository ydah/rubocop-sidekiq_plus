# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Sidekiq
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-sidekiq',
          version: VERSION,
          homepage: 'https://github.com/ydah/rubocop-sidekiq',
          description: 'Code style checking for Sidekiq.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: CONFIG_DEFAULT.to_s
        )
      end
    end
  end
end
