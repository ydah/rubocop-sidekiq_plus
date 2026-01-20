# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for usage of `perform_inline` in production code.
      #
      # `perform_inline` executes the job synchronously, bypassing the
      # job queue. This can be useful in tests but should generally be
      # avoided in production code.
      #
      # @example AllowedInTests: true (default)
      #   # bad (in app/services/user_service.rb)
      #   MyJob.perform_inline(user.id)
      #
      #   # good (in spec/jobs/my_job_spec.rb)
      #   MyJob.perform_inline(user.id)
      #
      # @example AllowedInTests: false
      #   # bad (in any file)
      #   MyJob.perform_inline(user.id)
      #
      class PerformInlineUsage < Base
        MSG = 'Avoid using `perform_inline` in production code. ' \
              'Use `perform_async` instead.'

        RESTRICT_ON_SEND = %i[perform_inline].freeze

        def on_send(node)
          return if allowed_in_tests? && in_test_file?

          add_offense(node)
        end
        alias on_csend on_send

        private

        def allowed_in_tests?
          cop_config.fetch('AllowedInTests', true)
        end

        def in_test_file?
          file_path = processed_source.file_path
          test_file_pattern.any? { |pattern| file_path.include?(pattern) }
        end

        def test_file_pattern
          %w[_spec.rb _test.rb /spec/ /test/]
        end
      end
    end
  end
end
