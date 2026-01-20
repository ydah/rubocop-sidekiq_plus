# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::UniqueJobWithoutTTL do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/UniqueJobWithoutTTL' => {} } }

  it 'registers an offense when unique_until is used without unique_for' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_until: :start
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `unique_for` option when using unique jobs.
      end
    RUBY
  end

  it 'registers an offense with multiple options but missing unique_for' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options queue: 'default', unique_until: :success, retry: 5
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `unique_for` option when using unique jobs.
      end
    RUBY
  end

  it 'does not register an offense when both unique_for and unique_until are specified' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 3600, unique_until: :start
      end
    RUBY
  end

  it 'does not register an offense when only unique_for is specified' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 1.hour
      end
    RUBY
  end

  it 'does not register an offense for regular sidekiq_options' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options queue: 'default', retry: 5
      end
    RUBY
  end
end
