# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Shared helpers for working with the current file path.
      module ProcessedSourcePath
        private

        def processed_file_path
          file_path = processed_source.file_path
          return if file_path.nil? || file_path == '(string)'

          file_path
        end
      end
    end
  end
end
