# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::LimiterWithoutLockTimeout do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/LimiterWithoutLockTimeout' => {} } }

  it 'registers an offense when concurrent limiter has no lock_timeout' do
    expect_offense(<<~RUBY)
      LIMITER = Sidekiq::Limiter.concurrent('erp', 50, wait_timeout: 0)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `lock_timeout` option for concurrent limiters to match job execution time.
    RUBY
  end

  it 'registers an offense for concurrent limiter without options' do
    expect_offense(<<~RUBY)
      LIMITER = Sidekiq::Limiter.concurrent('api', 10)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `lock_timeout` option for concurrent limiters to match job execution time.
    RUBY
  end

  it 'does not register an offense when lock_timeout is specified' do
    expect_no_offenses(<<~RUBY)
      LIMITER = Sidekiq::Limiter.concurrent('erp', 50, wait_timeout: 0, lock_timeout: 120)
    RUBY
  end

  it 'does not register an offense for bucket limiter' do
    expect_no_offenses(<<~RUBY)
      LIMITER = Sidekiq::Limiter.bucket('api', 100, wait_timeout: 0)
    RUBY
  end

  it 'does not register an offense for window limiter' do
    expect_no_offenses(<<~RUBY)
      LIMITER = Sidekiq::Limiter.window('api', 1000, :hour, wait_timeout: 0)
    RUBY
  end

  it 'does not register an offense for leaky limiter' do
    expect_no_offenses(<<~RUBY)
      LIMITER = Sidekiq::Limiter.leaky('api', 10, wait_timeout: 0)
    RUBY
  end
end
