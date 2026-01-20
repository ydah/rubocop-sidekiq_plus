# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::RetrySpecified, :config do
  context 'without retry specification' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          ^^^^^^^^^^^^^^^^^^^^ Specify retry configuration for this Sidekiq job using `sidekiq_options retry: ...`.
        end
      RUBY
    end

    it 'registers an offense for Sidekiq::Worker' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Worker
          ^^^^^^^^^^^^^^^^^^^^^^^ Specify retry configuration for this Sidekiq job using `sidekiq_options retry: ...`.
        end
      RUBY
    end
  end

  context 'with retry specification' do
    it 'does not register an offense with integer' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options retry: 5
        end
      RUBY
    end

    it 'does not register an offense with false' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options retry: false
        end
      RUBY
    end

    it 'does not register an offense with multiple options' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options queue: :default, retry: 3
        end
      RUBY
    end
  end

  context 'with sidekiq_options but no retry' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          ^^^^^^^^^^^^^^^^^^^^ Specify retry configuration for this Sidekiq job using `sidekiq_options retry: ...`.
          sidekiq_options queue: :default
        end
      RUBY
    end
  end

  context 'when in a non-Sidekiq class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyService
          def call
          end
        end
      RUBY
    end
  end
end
