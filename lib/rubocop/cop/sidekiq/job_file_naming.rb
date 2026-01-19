# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks that job file names match the class name.
      #
      # @example
      #   # bad - file: send_email_worker.rb
      #   class SendEmailJob
      #     include Sidekiq::Job
      #   end
      #
      class JobFileNaming < Base
        MSG = 'Job file name should match the class name.'

        def on_class(node)
          return unless sidekiq_job_class?(node)

          file_path = processed_source.file_path
          return if file_path.nil? || file_path == '(string)'

          class_name = class_name(node)
          return unless class_name

          expected = underscore(class_name)
          actual = File.basename(file_path, '.rb')
          return if expected == actual

          add_offense(node.loc.keyword)
        end

        private

        def class_name(node)
          identifier = node.identifier
          return unless identifier&.const_type?

          identifier.const_name.split('::').last
        end

        def underscore(name)
          name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
        end
      end
    end
  end
end
