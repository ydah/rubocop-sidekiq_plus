# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::LimiterNotReused do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/LimiterNotReused' => {} } }

  it 'registers an offense when limiter is created inside perform' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          limiter = Sidekiq::Limiter.concurrent('api', 50)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Create rate limiters as class constants for reuse.
          limiter.within_limit { call_api }
        end
      end
    RUBY
  end

  it 'registers an offense for bucket limiter inside method' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          limiter = Sidekiq::Limiter.bucket('api', 100)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Create rate limiters as class constants for reuse.
          limiter.within_limit { call_api }
        end
      end
    RUBY
  end

  it 'does not register an offense when limiter is a class constant' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        API_LIMITER = Sidekiq::Limiter.concurrent('api', 50, wait_timeout: 0)

        def perform
          API_LIMITER.within_limit { call_api }
        end
      end
    RUBY
  end

  it 'does not register an offense for dynamic limiter name with interpolation' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform(user_id)
          limiter = Sidekiq::Limiter.concurrent("api-\#{user_id}", 10)
          limiter.within_limit { call_api_for_user(user_id) }
        end
      end
    RUBY
  end

  it 'does not register an offense for dynamic limiter name from method call' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform(user_id)
          limiter = Sidekiq::Limiter.concurrent(limiter_name(user_id), 10)
          limiter.within_limit { call_api }
        end
      end
    RUBY
  end
end
