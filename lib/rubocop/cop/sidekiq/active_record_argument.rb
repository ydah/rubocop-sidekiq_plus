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
        include ArgumentTraversal

        MSG = 'Do not pass ActiveRecord objects to Sidekiq jobs. ' \
              'Pass the id and fetch the record in the job instead.'

        RESTRICT_ON_SEND = PerformMethods.all

        FINDER_METHODS = %i[find find_by find_by! first last take where].freeze

        # @!method sidekiq_perform_call?(node)
        def_node_matcher :sidekiq_perform_call?, <<~PATTERN
          (send _ {#{PerformMethods.all.map(&:inspect).join(' ')}} $...)
        PATTERN

        # @!method active_record_finder?(node)
        def_node_matcher :active_record_finder?, <<~PATTERN
          (send (const ...) {#{FINDER_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        # @!method chained_finder?(node)
        def_node_matcher :chained_finder?, <<~PATTERN
          (send (send (const ...) ...) {#{FINDER_METHODS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def on_send(node)
          sidekiq_perform_call?(node) do |args|
            check_arguments(args)
          end
        end
        alias on_csend on_send

        private

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
      end
    end
  end
end
