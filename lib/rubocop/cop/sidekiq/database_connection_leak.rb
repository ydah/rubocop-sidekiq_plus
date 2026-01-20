# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Checks for explicit ActiveRecord connection usage in Sidekiq jobs.
      #
      # @example
      #   # bad
      #   ActiveRecord::Base.connection.execute('SELECT 1')
      #
      #   # good
      #   ActiveRecord::Base.connection_pool.with_connection { |conn| conn.execute('SELECT 1') }
      #
      class DatabaseConnectionLeak < Base
        MSG = 'Avoid using ActiveRecord::Base.connection directly in jobs. Use connection_pool.with_connection.'

        def on_def(node)
          return unless node.method?(:perform)
          return unless in_sidekiq_job?(node)

          node.each_descendant(:send) do |send|
            receiver = send.receiver
            next unless receiver&.const_name == 'ActiveRecord::Base'
            next unless send.method?(:connection)

            add_offense(send)
          end
        end
      end
    end
  end
end
