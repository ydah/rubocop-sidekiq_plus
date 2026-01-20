# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::PerformMethodParameters, :config do
  context 'when in a Sidekiq job class' do
    it 'registers an offense for required keyword arguments' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(user_id:, status:)
                      ^^^^^^^^ Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
                                ^^^^^^^ Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
          end
        end
      RUBY
    end

    it 'registers an offense for optional keyword arguments' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(id, status: 'pending')
                          ^^^^^^^^^^^^^^^^^ Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
          end
        end
      RUBY
    end

    it 'registers an offense for keyword rest arguments' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform(**options)
                      ^^^^^^^^^ Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
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

  context 'when in a Sidekiq::Worker class' do
    it 'registers an offense for keyword arguments' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Worker

          def perform(user_id:)
                      ^^^^^^^^ Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.
          end
        end
      RUBY
    end
  end

  context 'when outside a Sidekiq job class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyService
          def perform(user_id:, status:)
          end
        end
      RUBY
    end
  end

  context 'when checking non-perform methods' do
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
