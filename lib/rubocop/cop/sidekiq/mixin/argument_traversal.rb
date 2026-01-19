# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Shared helpers for traversing Sidekiq job arguments.
      module ArgumentTraversal
        private

        def check_arguments(args, **kwargs)
          args.each { |arg| check_argument(arg, **kwargs) }
        end

        def check_hash_values(hash_node, **kwargs)
          hash_node.each_pair do |_key, value|
            check_argument(value, **kwargs)
          end
        end

        def check_array_elements(array_node, **kwargs)
          array_node.each_child_node do |element|
            check_argument(element, **kwargs)
          end
        end
      end
    end
  end
end
