# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::EncryptionWithManyArguments, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/EncryptionWithManyArguments' => { 'MaxArguments' => 2 } } }

  it 'registers an offense when encrypted job has too many arguments' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(password, user_id, options)
            ^^^^^^^ Encrypted jobs should use a secret bag pattern. Only the last argument is encrypted; consider consolidating sensitive data.
        end
      end
    RUBY
  end

  it 'registers an offense for 4 arguments with encryption' do
    expect_offense(<<~RUBY)
      class SecureJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(id, name, email, secrets)
            ^^^^^^^ Encrypted jobs should use a secret bag pattern. Only the last argument is encrypted; consider consolidating sensitive data.
        end
      end
    RUBY
  end

  it 'does not register an offense when encrypted job has 2 arguments' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(user_id, secret_bag)
        end
      end
    RUBY
  end

  it 'does not register an offense when encrypted job has 1 argument' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: true

        def perform(encrypted_data)
        end
      end
    RUBY
  end

  it 'does not register an offense when encryption is not enabled' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options retry: 5

        def perform(a, b, c, d, e)
        end
      end
    RUBY
  end

  it 'does not register an offense when encryption is false' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
        sidekiq_options encrypt: false

        def perform(a, b, c, d)
        end
      end
    RUBY
  end

  context 'with custom MaxArguments' do
    let(:cop_config) { { 'SidekiqEnt/EncryptionWithManyArguments' => { 'MaxArguments' => 3 } } }

    it 'does not register an offense when within custom limit' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options encrypt: true

          def perform(id, name, secrets)
          end
        end
      RUBY
    end

    it 'registers an offense when exceeding custom limit' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options encrypt: true

          def perform(id, name, email, secrets)
              ^^^^^^^ Encrypted jobs should use a secret bag pattern. Only the last argument is encrypted; consider consolidating sensitive data.
          end
        end
      RUBY
    end
  end
end
