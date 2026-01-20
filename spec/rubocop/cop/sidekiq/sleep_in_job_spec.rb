# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::SleepInJob, :config do
  context 'when in a Sidekiq job' do
    it 'registers an offense for sleep' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            sleep 5
            ^^^^^^^ Do not use `sleep` in Sidekiq jobs. It blocks the worker thread. Use `perform_in` or `perform_at` instead.
          end
        end
      RUBY
    end

    it 'registers an offense for sleep with parentheses' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            sleep(10)
            ^^^^^^^^^ Do not use `sleep` in Sidekiq jobs. It blocks the worker thread. Use `perform_in` or `perform_at` instead.
          end
        end
      RUBY
    end

    it 'registers an offense for Kernel.sleep' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            Kernel.sleep(5)
            ^^^^^^^^^^^^^^^ Do not use `sleep` in Sidekiq jobs. It blocks the worker thread. Use `perform_in` or `perform_at` instead.
          end
        end
      RUBY
    end

    it 'registers an offense for sleep in private method' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            do_work
          end

          private

          def do_work
            sleep 1
            ^^^^^^^ Do not use `sleep` in Sidekiq jobs. It blocks the worker thread. Use `perform_in` or `perform_at` instead.
          end
        end
      RUBY
    end
  end

  context 'when in a Sidekiq::Worker class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Worker

          def perform
            sleep 5
            ^^^^^^^ Do not use `sleep` in Sidekiq jobs. It blocks the worker thread. Use `perform_in` or `perform_at` instead.
          end
        end
      RUBY
    end
  end

  context 'when outside a Sidekiq job' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyService
          def call
            sleep 5
          end
        end
      RUBY
    end
  end

  context 'when in a regular class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class RegularClass
          def wait
            sleep 1
          end
        end
      RUBY
    end
  end
end
