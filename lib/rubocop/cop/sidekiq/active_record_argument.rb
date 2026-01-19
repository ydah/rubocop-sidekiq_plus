# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for ActiveRecord objects passed to Sidekiq job methods.
      #
      # Passing ActiveRecord objects to Sidekiq jobs is problematic because:
      # - Objects cannot be properly serialized to JSON
      # - The object may change or be deleted before the job runs
      # - It increases Redis memory usage
      #
      # Instead, pass the record's ID and reload it in the job.
      #
      # @example
      #   # bad
      #   MyJob.perform_async(user)
      #   MyJob.perform_async(User.find(1))
      #   MyJob.perform_async(User.first)
      #
      #   # good
      #   MyJob.perform_async(user.id)
      #   MyJob.perform_async(user_id)
      #
      class ActiveRecordArgument < Base
        MSG = 'Do not pass ActiveRecord objects to Sidekiq jobs. ' \
              'Pass the id and fetch the record in the job instead.'

        PERFORM_METHODS = %i[perform_async perform_in perform_at perform_bulk].freeze

        RESTRICT_ON_SEND = PERFORM_METHODS

        FINDER_METHODS = %i[find find_by find_by! first last take where].freeze

        def_node_matcher :sidekiq_perform_call?, <<~PATTERN
          (send _ {#{PERFORM_METHODS.map(&:inspect).join(' ')}} $...)
        PATTERN

        def_node_matcher :active_record_finder?, <<~PATTERN
          (send (const ...) {#{FINDER_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def_node_matcher :chained_finder?, <<~PATTERN
          (send (send (const ...) ...) {#{FINDER_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def on_send(node)
          sidekiq_perform_call?(node) do |args|
            check_arguments(args)
          end
        end

        private

        def check_arguments(args)
          args.each do |arg|
            check_argument(arg)
          end
        end

        def check_argument(arg)
          if active_record_object?(arg)
            add_offense(arg)
          elsif arg.hash_type?
            check_hash_values(arg)
          elsif arg.array_type?
            check_array_elements(arg)
          end
        end

        def active_record_object?(node)
          return false unless node.send_type?

          active_record_finder?(node) || chained_finder?(node)
        end

        def check_hash_values(hash_node)
          hash_node.each_pair do |_key, value|
            check_argument(value)
          end
        end

        def check_array_elements(array_node)
          array_node.each_child_node do |element|
            check_argument(element)
          end
        end
      end
    end
  end
end
