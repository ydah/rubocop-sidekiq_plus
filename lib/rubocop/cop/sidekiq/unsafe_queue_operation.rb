# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for unsafe Sidekiq queue/set iteration and lookup operations.
      #
      # The Sidekiq API operates on shared mutable data structures within Redis
      # without locks. Iteration through queues/sets is best effort and results
      # cannot be guaranteed. For example, `find_job` might miss a job if the
      # queue is mutated during iteration.
      #
      # These operations are not scalable and should not be used in an automated
      # fashion or in bulk as part of your application functionality.
      #
      # @safety
      #   This cop may flag legitimate uses in rake tasks or manual repair scripts.
      #   Use `# rubocop:disable` comments for those cases.
      #
      # @example
      #   # bad - find_job has race conditions
      #   Sidekiq::Queue.new.find_job(jid)
      #
      #   # bad - iterating and deleting jobs
      #   Sidekiq::Queue.new.each { |job| job.delete }
      #
      #   # bad - scanning retry set
      #   Sidekiq::RetrySet.new.select { |job| job.jid == jid }
      #
      #   # bad - scanning scheduled set
      #   Sidekiq::ScheduledSet.new.find { |job| job.item['class'] == 'MyJob' }
      #
      #   # good - use Sidekiq Pro's delete_job/delete_by_class if available
      #   # or reconsider the design to avoid queue scanning
      #
      class UnsafeQueueOperation < Base
        MSG = 'Avoid `%<method>s` on Sidekiq queues/sets in application code. ' \
              'These operations have race conditions and are not scalable.'

        RESTRICT_ON_SEND = %i[
          find_job
          each
          map
          select
          find
          reject
          any?
          all?
          none?
          count
          size
          first
          last
          clear
        ].freeze

        SIDEKIQ_QUEUE_CLASSES = %w[
          Queue
          RetrySet
          ScheduledSet
          DeadSet
        ].freeze

        # @!method sidekiq_queue_receiver?(node)
        def_node_matcher :sidekiq_queue_receiver?, <<~PATTERN
          (send
            (send
              (const (const {nil? cbase} :Sidekiq) {#{SIDEKIQ_QUEUE_CLASSES.map { |c| ":#{c}" }.join(' ')}})
              :new
              ...
            )
            $_method
            ...
          )
        PATTERN

        def on_send(node)
          sidekiq_queue_receiver?(node) do |method|
            next unless RESTRICT_ON_SEND.include?(method)

            add_offense(node, message: format(MSG, method: method))
          end
        end
        alias on_csend on_send
      end
    end
  end
end
