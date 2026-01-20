# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::MixedRetryStrategies, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/MixedRetryStrategies' => {} } }

  it 'registers an offense when retry_on and sidekiq_options retry are mixed' do
    expect_offense(<<~RUBY)
      class MyJob < ApplicationJob
        retry_on SomeError
        sidekiq_options retry: 5
        ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid mixing ActiveJob retry_on with Sidekiq retry options.
      end
    RUBY
  end

  it 'does not register an offense when sidekiq retry is disabled' do
    expect_no_offenses(<<~RUBY)
      class MyJob < ApplicationJob
        retry_on SomeError
        sidekiq_options retry: false
      end
    RUBY
  end
end
