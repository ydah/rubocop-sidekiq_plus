# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::DeprecatedDelayExtension, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/DeprecatedDelayExtension' => {} } }

  it 'registers an offense for delay extension usage' do
    expect_offense(<<~RUBY)
      UserMailer.delay.welcome_email(user)
                 ^^^^^ Avoid using the delay extension. Use `deliver_later` or enqueue a Sidekiq job instead.
    RUBY
  end

  it 'does not register an offense for delay with arguments' do
    expect_no_offenses(<<~RUBY)
      SomeService.delay(5)
    RUBY
  end
end
