# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::JobInclude do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }

  context 'when PreferredModule is Job (default)' do
    let(:cop_config) do
      { 'Sidekiq/JobInclude' => { 'PreferredModule' => 'Job' } }
    end

    it 'registers an offense for Sidekiq::Worker' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Worker
          ^^^^^^^^^^^^^^^^^^^^^^^ Use `Sidekiq::Job` instead of `Sidekiq::Worker`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyJob
          include Sidekiq::Job
        end
      RUBY
    end

    it 'does not register an offense for Sidekiq::Job' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
        end
      RUBY
    end
  end

  context 'when PreferredModule is Worker' do
    let(:cop_config) do
      { 'Sidekiq/JobInclude' => { 'PreferredModule' => 'Worker' } }
    end

    it 'registers an offense for Sidekiq::Job' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          ^^^^^^^^^^^^^^^^^^^^ Use `Sidekiq::Worker` instead of `Sidekiq::Job`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyJob
          include Sidekiq::Worker
        end
      RUBY
    end

    it 'does not register an offense for Sidekiq::Worker' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Worker
        end
      RUBY
    end
  end

  context 'with fully qualified constant' do
    let(:cop_config) do
      { 'Sidekiq/JobInclude' => { 'PreferredModule' => 'Job' } }
    end

    it 'registers an offense for ::Sidekiq::Worker' do
      expect_offense(<<~RUBY)
        class MyJob
          include ::Sidekiq::Worker
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Sidekiq::Job` instead of `Sidekiq::Worker`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyJob
          include Sidekiq::Job
        end
      RUBY
    end
  end
end
