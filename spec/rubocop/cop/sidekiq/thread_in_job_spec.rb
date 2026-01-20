# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::ThreadInJob, :config do
  context 'when in a Sidekiq job' do
    it 'registers an offense for Thread.new' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            Thread.new { do_work }
            ^^^^^^^^^^ Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end

    it 'registers an offense for Thread.fork' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            Thread.fork { do_work }
            ^^^^^^^^^^^ Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end

    it 'registers an offense for Thread.new with block argument' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            Thread.new(data) { |d| process(d) }
            ^^^^^^^^^^^^^^^^ Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end

    it 'registers an offense in private methods' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            spawn_worker
          end

          private

          def spawn_worker
            Thread.new { work }
            ^^^^^^^^^^ Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
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
            Thread.new { work }
            ^^^^^^^^^^ Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
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
            Thread.new { do_work }
          end
        end
      RUBY
    end
  end

  context 'when using fully qualified constant' do
    it 'registers an offense for ::Thread.new' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            ::Thread.new { do_work }
            ^^^^^^^^^^^^ Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end
  end
end
