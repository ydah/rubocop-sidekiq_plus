# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks that Sidekiq job classes are located in allowed directories.
      #
      # @example
      #   # bad - app/models/send_email_job.rb
      #   class SendEmailJob
      #     include Sidekiq::Job
      #   end
      #
      #   # good - app/jobs/send_email_job.rb
      #   class SendEmailJob
      #     include Sidekiq::Job
      #   end
      #
      class JobFileLocation < Base
        include ProcessedSourcePath

        MSG = 'Place Sidekiq job classes under %<dirs>s.'

        DEFAULT_DIRECTORIES = ['app/jobs', 'app/workers'].freeze

        def on_class(node)
          return unless sidekiq_job_class?(node)

          file_path = processed_file_path
          return unless file_path

          return if in_allowed_directory?(file_path)

          add_offense(node.loc.keyword, message: format(MSG, dirs: allowed_directories.join(' or ')))
        end

        private

        def allowed_directories
          cop_config.fetch('AllowedDirectories', DEFAULT_DIRECTORIES)
        end

        def in_allowed_directory?(file_path)
          allowed_directories.any? do |dir|
            file_path.include?("/#{dir}/") || file_path.include?("#{dir}/") ||
              file_path.end_with?("/#{dir}") || file_path.end_with?(dir)
          end
        end
      end
    end
  end
end
