# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::PerformMethodSignature do
  subject(:cop) { described_class.new }

  context 'in a Sidekiq job class' do
    it 'registers an offense for required keyword arguments' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(user_id:, status:)
                      ^^^^^^^^ Sidekiq/PerformMethodSignature: Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
                                ^^^^^^^ Sidekiq/PerformMethodSignature: Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
          end
        end
      RUBY
    end

    it 'registers an offense for optional keyword arguments' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(id, status: 'pending')
                          ^^^^^^^^^^^^^^^^^ Sidekiq/PerformMethodSignature: Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
          end
        end
      RUBY
    end

    it 'registers an offense for keyword rest arguments' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(**options)
                      ^^^^^^^^^ Sidekiq/PerformMethodSignature: Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
          end
        end
      RUBY
    end

    it 'does not register an offense for positional arguments' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(user_id, status)
          end
        end
      RUBY
    end

    it 'does not register an offense for rest arguments' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(*args)
          end
        end
      RUBY
    end

    it 'does not register an offense for optional positional arguments' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(id, status = 'pending')
          end
        end
      RUBY
    end
  end

  context 'in a Sidekiq::Worker class' do
    it 'registers an offense for keyword arguments' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Worker

          def perform(user_id:)
                      ^^^^^^^^ Sidekiq/PerformMethodSignature: Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
          end
        end
      RUBY
    end
  end

  context 'outside a Sidekiq job class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyService
          def perform(user_id:, status:)
          end
        end
      RUBY
    end
  end

  context 'for non-perform methods' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def process(user_id:)
          end
        end
      RUBY
    end
  end
end
