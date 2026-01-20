# frozen_string_literal: true

module RuboCop
  module Cop
    module SidekiqEnt
      # Checks that periodic jobs do not require arguments without defaults.
      #
      # Periodic jobs are scheduled by cron and cannot receive dynamic arguments
      # unless specified via the `args` option in the periodic registration.
      # A perform method requiring arguments will fail when called periodically.
      #
      # @example
      #   # bad - requires arguments
      #   class HourlyReportJob
      #     include Sidekiq::Job
      #
      #     def perform(user_id)
      #     end
      #   end
      #
      #   # good - no arguments
      #   class HourlyReportJob
      #     include Sidekiq::Job
      #
      #     def perform
      #     end
      #   end
      #
      #   # good - optional arguments with defaults
      #   class HourlyReportJob
      #     include Sidekiq::Job
      #
      #     def perform(scope = 'all')
      #     end
      #   end
      #
      class PeriodicJobWithArguments < Base
        include RuboCop::Sidekiq::Language

        MSG = 'Periodic job `perform` should not require arguments. ' \
              'Use optional arguments or the `args` option in periodic registration.'

        # @!method periodic_register?(node)
        def_node_matcher :periodic_register?, <<~PATTERN
          (send _ :register (str _) {(str $_) (const ... $_)} ...)
        PATTERN

        def on_send(node)
          periodic_register?(node) do |job_class_name|
            job_class_name = job_class_name.to_s
            check_job_class(node, job_class_name)
          end
        end
        alias on_csend on_send

        private

        def check_job_class(register_node, job_class_name)
          return if args_option?(register_node)

          find_job_class(job_class_name)&.then do |class_node|
            perform_method = find_perform_method(class_node)
            add_offense(perform_method.loc.name) if perform_method && requires_arguments?(perform_method)
          end
        end

        def args_option?(node)
          options_hash = node.arguments.find(&:hash_type?)
          return false unless options_hash

          options_hash.pairs.any? { |pair| pair.key.value == :args }
        end

        def find_job_class(class_name)
          processed_source.ast.each_descendant(:class).find do |class_node|
            class_node.identifier.source == class_name.split('::').last
          end
        end

        def find_perform_method(class_node)
          class_node.body&.each_descendant(:def)&.find do |def_node|
            def_node.method?(:perform)
          end
        end

        def requires_arguments?(method_node)
          method_node.arguments.any? do |arg|
            arg.type?(:arg, :kwarg)
          end
        end
      end
    end
  end
end
