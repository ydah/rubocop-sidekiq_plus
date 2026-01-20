# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::EncryptionWithoutSecretBag do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/EncryptionWithoutSecretBag' => {} } }

  it 'registers an offense when encrypted job has only user_id argument' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(user_id)
            ^^^^^^^ Encrypted job has only one argument. Consider if encryption is necessary or add a secret bag argument.
        end
      end
    RUBY
  end

  it 'registers an offense when encrypted job has only id argument' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(id)
            ^^^^^^^ Encrypted job has only one argument. Consider if encryption is necessary or add a secret bag argument.
        end
      end
    RUBY
  end

  it 'registers an offense when encrypted job has only record_id argument' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(record_id)
            ^^^^^^^ Encrypted job has only one argument. Consider if encryption is necessary or add a secret bag argument.
        end
      end
    RUBY
  end

  it 'does not register an offense when encrypted job has multiple arguments' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(user_id, secret_data)
        end
      end
    RUBY
  end

  it 'does not register an offense when single argument is not id-like' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(credentials)
        end
      end
    RUBY
  end

  it 'does not register an offense when encryption is not enabled' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options retry: 5

        def perform(user_id)
        end
      end
    RUBY
  end

  it 'does not register an offense when job has no arguments' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform
        end
      end
    RUBY
  end
end
