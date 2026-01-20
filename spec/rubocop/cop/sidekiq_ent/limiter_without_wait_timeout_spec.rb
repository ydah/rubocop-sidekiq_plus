# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::LimiterWithoutWaitTimeout do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/LimiterWithoutWaitTimeout' => {} } }

  it 'registers an offense when wait_timeout is not specified' do
    expect_offense(<<~RUBY)
      API_LIMITER = Sidekiq::Limiter.concurrent('api', 50)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `wait_timeout` option for rate limiters to avoid blocking worker threads.
    RUBY
  end

  it 'registers an offense for bucket limiter without wait_timeout' do
    expect_offense(<<~RUBY)
      API_LIMITER = Sidekiq::Limiter.bucket('api', 100)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `wait_timeout` option for rate limiters to avoid blocking worker threads.
    RUBY
  end

  it 'registers an offense for window limiter without wait_timeout' do
    expect_offense(<<~RUBY)
      API_LIMITER = Sidekiq::Limiter.window('api', 1000)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `wait_timeout` option for rate limiters to avoid blocking worker threads.
    RUBY
  end

  it 'does not register an offense when wait_timeout is specified' do
    expect_no_offenses(<<~RUBY)
      API_LIMITER = Sidekiq::Limiter.concurrent('api', 50, wait_timeout: 0)
    RUBY
  end

  it 'does not register an offense when wait_timeout has a value' do
    expect_no_offenses(<<~RUBY)
      API_LIMITER = Sidekiq::Limiter.concurrent('api', 50, wait_timeout: 5)
    RUBY
  end

  it 'does not register an offense with other options and wait_timeout' do
    expect_no_offenses(<<~RUBY)
      API_LIMITER = Sidekiq::Limiter.concurrent('api', 50, wait_timeout: 0, lock_timeout: 10)
    RUBY
  end
end
