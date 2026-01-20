# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::UniqueJobTooShortTTL do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/UniqueJobTooShortTTL' => { 'MinimumTTL' => 60 } } }

  it 'registers an offense when unique_for is too short (integer seconds)' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 30
                                    ^^ Unique job TTL is too short (minimum: 60 seconds). Consider increasing `unique_for` to cover retry period.
      end
    RUBY
  end

  it 'registers an offense when unique_for uses duration helper (seconds)' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 30.seconds
                                    ^^^^^^^^^^ Unique job TTL is too short (minimum: 60 seconds). Consider increasing `unique_for` to cover retry period.
      end
    RUBY
  end

  it 'does not register an offense when unique_for is adequate (integer)' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 600
      end
    RUBY
  end

  it 'does not register an offense when unique_for uses minutes' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 10.minutes
      end
    RUBY
  end

  it 'does not register an offense when unique_for uses hours' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 1.hour
      end
    RUBY
  end

  it 'does not register an offense when unique_for is exactly at minimum' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 60
      end
    RUBY
  end

  it 'does not register an offense when unique_for is 1 minute' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 1.minute
      end
    RUBY
  end

  it 'does not register an offense without unique_for option' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options retry: 5
      end
    RUBY
  end
end
