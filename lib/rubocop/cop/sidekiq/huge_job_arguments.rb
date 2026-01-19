# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for potentially huge arguments passed to Sidekiq jobs.
      #
      # @example
      #   # bad
      #   MyJob.perform_async(users.pluck(:id, :name, :email))
      #   MyJob.perform_async([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
      #
      #   # good
      #   MyJob.perform_async(user_ids)
      #
      class HugeJobArguments < Base
        MSG = 'Avoid passing large arguments to Sidekiq jobs. Pass IDs and load records in the job instead.'

        DEFAULT_MAX_ARRAY_SIZE = 10
        DEFAULT_MAX_HASH_SIZE = 10
        DEFAULT_MAX_PLUCK_COLUMNS = 3

        def on_send(node)
          perform_call?(node) do
            node.arguments.each do |arg|
              check_argument(arg)
            end
          end
        end

        private

        def check_argument(arg)
          return unless large_pluck?(arg) || large_array?(arg) || large_hash?(arg)

          add_offense(arg)
        end

        def large_pluck?(arg)
          return false unless arg.send_type?
          return false unless arg.method_name == :pluck

          arg.arguments.size >= max_pluck_columns
        end

        def large_array?(arg)
          return false unless arg.array_type?

          arg.values.size > max_array_size
        end

        def large_hash?(arg)
          return false unless arg.hash_type?

          arg.pairs.size > max_hash_size
        end

        def max_array_size
          cop_config.fetch('MaxArraySize', DEFAULT_MAX_ARRAY_SIZE)
        end

        def max_hash_size
          cop_config.fetch('MaxHashSize', DEFAULT_MAX_HASH_SIZE)
        end

        def max_pluck_columns
          cop_config.fetch('MaxPluckColumns', DEFAULT_MAX_PLUCK_COLUMNS)
        end
      end
    end
  end
end
