# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::PreferSidekiqOverActiveJob, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/PreferSidekiqOverActiveJob' => {} } }

  it 'registers an offense for ApplicationJob subclasses' do
    expect_offense(<<~RUBY)
      class MyJob < ApplicationJob
      ^^^^^ Prefer Sidekiq::Job over ActiveJob for Sidekiq-specific features.
        def perform; end
      end
    RUBY
  end

  it 'does not register an offense for Sidekiq::Job classes' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job
      end
    RUBY
  end
end
