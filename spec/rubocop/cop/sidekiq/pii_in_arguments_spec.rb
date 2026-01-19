# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::PiiInArguments do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/PiiInArguments' => {} } }

  it 'registers an offense for PII hash keys' do
    expect_offense(<<~RUBY)
      NotifyJob.perform_async(email: 'user@example.com')
                              ^^^^^ Avoid passing PII in Sidekiq job arguments.
    RUBY
  end

  it 'does not register an offense for non-PII arguments' do
    expect_no_offenses(<<~RUBY)
      NotifyJob.perform_async(user_id)
    RUBY
  end
end
