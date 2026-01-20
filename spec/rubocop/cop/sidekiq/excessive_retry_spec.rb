# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::ExcessiveRetry, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/ExcessiveRetry' => { 'MaxRetries' => 10 } } }

  it 'registers an offense when retry exceeds MaxRetries' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        sidekiq_options retry: 11
                               ^^ Retry count exceeds the maximum allowed (10).
      end
    RUBY
  end

  it 'does not register an offense within MaxRetries' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        sidekiq_options retry: 5
      end
    RUBY
  end
end
