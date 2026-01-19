# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for network calls without explicit timeouts in Sidekiq jobs.
      #
      # @example
      #   # bad
      #   Net::HTTP.get(URI(url))
      #
      #   # good
      #   http.open_timeout = 5
      #   http.read_timeout = 10
      #
      class MissingTimeout < Base
        MSG = 'Configure explicit timeouts for network calls in Sidekiq jobs.'

        HTTP_METHODS = %i[get post put delete].freeze

        def on_def(node)
          return unless node.method_name == :perform
          return unless in_sidekiq_job?(node)
          return if timeout_configured?(node)

          node.each_descendant(:send) do |send|
            next unless network_call?(send)

            add_offense(send)
          end
        end

        private

        def timeout_configured?(def_node)
          def_node.each_descendant(:send).any? do |send|
            %i[timeout= open_timeout= read_timeout=].include?(send.method_name)
          end
        end

        def network_call?(send)
          receiver = send.receiver
          const_name = receiver&.const_name
          return false unless const_name

          return %i[get get_response start].include?(send.method_name) if const_name == 'Net::HTTP'

          library_http_methods?(const_name, send.method_name)
        end

        def library_http_methods?(const_name, method_name)
          return method_name == :new if const_name == 'Faraday'
          return HTTP_METHODS.include?(method_name) if http_libraries.include?(const_name)

          false
        end

        def http_libraries
          %w[HTTParty RestClient HTTP Typhoeus].freeze
        end
      end
    end
  end
end
