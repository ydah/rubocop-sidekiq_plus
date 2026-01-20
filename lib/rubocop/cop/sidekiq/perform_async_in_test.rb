# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for perform_async usage in test files.
      #
      # @example
      #   # bad
      #   MyJob.perform_async(user.id)
      #
      #   # good
      #   MyJob.perform_inline(user.id)
      #
      class PerformAsyncInTest < Base
        MSG = 'Avoid perform_async in tests. Use perform_inline or call perform directly.'

        RESTRICT_ON_SEND = %i[perform_async].freeze

        def on_send(node)
          return unless in_test_file?

          add_offense(node)
        end
        alias on_csend on_send

        private

        def in_test_file?
          file_path = processed_source.file_path
          return false unless file_path

          test_patterns.any? { |pattern| File.fnmatch?(pattern, file_path) }
        end

        def test_patterns
          cop_config.fetch('Include', ['spec/**/*_spec.rb', 'test/**/*_test.rb'])
        end
      end
    end
  end
end
