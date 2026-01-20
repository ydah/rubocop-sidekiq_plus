# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::SensitiveDataInArguments, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/SensitiveDataInArguments' => {} } }

  it 'registers an offense for sensitive argument names' do
    expect_offense(<<~RUBY)
      UserJob.perform_async(user_id, password)
                                     ^^^^^^^^ Avoid passing sensitive data in Sidekiq job arguments.
    RUBY
  end

  it 'registers an offense for sensitive hash keys' do
    expect_offense(<<~RUBY)
      UserJob.perform_async(password: 'secret')
                            ^^^^^^^^ Avoid passing sensitive data in Sidekiq job arguments.
    RUBY
  end

  it 'does not register an offense for non-sensitive arguments' do
    expect_no_offenses(<<~RUBY)
      UserJob.perform_async(user_id)
    RUBY
  end
end
