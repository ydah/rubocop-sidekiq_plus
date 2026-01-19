# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Shared helpers for extracting class names and file-friendly names.
      module ClassNameHelper
        private

        def class_name(node)
          identifier = node&.identifier
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
