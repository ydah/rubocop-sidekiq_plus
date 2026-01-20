# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::ExpiringJobWithoutTTL, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) do
    { 'SidekiqPro/ExpiringJobWithoutTTL' => { 'MinimumTTL' => 300, 'MaximumTTL' => 604_800 } }
  end

  it 'registers an offense when expires_in is too short (integer)' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options expires_in: 60
                                    ^^ Expiring job TTL is too short (minimum: 300 seconds). Jobs may expire before processing.
      end
    RUBY
  end

  it 'registers an offense when expires_in is too short (duration)' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options expires_in: 1.minute
                                    ^^^^^^^^ Expiring job TTL is too short (minimum: 300 seconds). Jobs may expire before processing.
      end
    RUBY
  end

  it 'registers an offense when expires_in is too long (duration)' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options expires_in: 30.days
                                    ^^^^^^^ Expiring job TTL is too long (maximum: 604800 seconds). Consider a shorter TTL for expiring jobs.
      end
    RUBY
  end

  it 'does not register an offense when expires_in is within range' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options expires_in: 1.hour
      end
    RUBY
  end

  it 'does not register an offense when expires_in is exactly at minimum' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options expires_in: 300
      end
    RUBY
  end

  it 'does not register an offense when expires_in is exactly at maximum' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options expires_in: 604800
      end
    RUBY
  end

  it 'does not register an offense without expires_in option' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options retry: 5
      end
    RUBY
  end
end
