# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::UniqueUntilMismatch, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/UniqueUntilMismatch' => { 'AllowedValues' => ['success'] } } }

  it 'registers an offense when unique_until is :start' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 600, unique_until: :start
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unique_until: :start`. Prefer `unique_until: :success` (default) to prevent concurrent execution.
      end
    RUBY
  end

  it 'does not register an offense when unique_until is :success' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 600, unique_until: :success
      end
    RUBY
  end

  it 'does not register an offense without unique_until option' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options unique_for: 600
      end
    RUBY
  end

  it 'does not register an offense for regular sidekiq_options' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options retry: 5, queue: 'default'
      end
    RUBY
  end

  context 'with custom allowed values' do
    let(:cop_config) { { 'SidekiqEnt/UniqueUntilMismatch' => { 'AllowedValues' => %w[success start] } } }

    it 'does not register an offense for custom allowed values' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options unique_for: 600, unique_until: :start
        end
      RUBY
    end
  end
end
