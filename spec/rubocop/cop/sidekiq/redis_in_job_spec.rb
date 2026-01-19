# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::RedisInJob do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/RedisInJob' => {} } }

  it 'registers an offense for Redis.new inside perform' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          Redis.new
          ^^^^^^^^^ Use Sidekiq.redis instead of creating a new Redis connection in jobs.
        end
      end
    RUBY
  end

  it 'does not register an offense for Sidekiq.redis usage' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          Sidekiq.redis { |conn| conn.get('key') }
        end
      end
    RUBY
  end
end
