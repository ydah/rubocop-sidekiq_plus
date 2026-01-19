# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::RetryZero do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/RetryZero' => {} } }

  it 'registers an offense for retry: 0' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        sidekiq_options retry: 0
                               ^ Use `retry: false` instead of `retry: 0` for clarity.
      end
    RUBY
  end

  it 'does not register an offense for retry: false' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        sidekiq_options retry: false
      end
    RUBY
  end
end
