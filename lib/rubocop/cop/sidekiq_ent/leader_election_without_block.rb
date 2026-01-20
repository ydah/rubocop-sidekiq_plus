# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks for potentially problematic leader election usage.
      #
      # Using `Sidekiq.leader?` for long-running operations can be
      # problematic if leadership changes during execution. Prefer
      # delegating work to a job.
      #
      # @example
      #   # bad - long-running operation in leader check
      #   if Sidekiq.leader?
      #     do_long_running_work
      #   end
      #
      #   # good - enqueue job for leader work
      #   if Sidekiq.leader?
      #     LeaderOnlyJob.perform_async
      #   end
      #
      class LeaderElectionWithoutBlock < Base
        MSG = 'Avoid long-running operations in leader checks. ' \
              'Consider delegating work to a job.'

        def_node_matcher :leader_check?, <<~PATTERN
          (send (const {nil? cbase} :Sidekiq) :leader?)
        PATTERN

        def_node_matcher :if_leader_condition?, <<~PATTERN
          (if (send (const {nil? cbase} :Sidekiq) :leader?) $_ $_)
        PATTERN

        def on_if(node)
          if_leader_condition?(node) do |then_branch, _else_branch|
            return unless then_branch

            add_offense(node) if contains_non_job_calls?(then_branch)
          end
        end

        private

        def contains_non_job_calls?(node)
          return false if only_job_enqueue?(node)

          case node.type
          when :begin
            node.children.any? { |child| contains_non_job_calls?(child) }
          when :send
            !job_enqueue_call?(node)
          else
            true
          end
        end

        def only_job_enqueue?(node)
          return job_enqueue_call?(node) if node.send_type?
          return node.children.all? { |child| child.send_type? && job_enqueue_call?(child) } if node.begin_type?

          false
        end

        def job_enqueue_call?(node)
          return false unless node.send_type?

          %i[perform_async perform_in perform_at].include?(node.method_name)
        end
      end
    end
  end
end
