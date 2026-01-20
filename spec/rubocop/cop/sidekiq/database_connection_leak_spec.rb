# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::DatabaseConnectionLeak, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/DatabaseConnectionLeak' => {} } }

  it 'registers an offense for direct connection usage' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          ActiveRecord::Base.connection
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using ActiveRecord::Base.connection directly in jobs. Use connection_pool.with_connection.
        end
      end
    RUBY
  end

  it 'does not register an offense for connection_pool usage' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          ActiveRecord::Base.connection_pool.with_connection { |conn| conn.execute('SELECT 1') }
        end
      end
    RUBY
  end
end
