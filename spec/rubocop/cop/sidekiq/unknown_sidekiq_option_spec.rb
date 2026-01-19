# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::UnknownSidekiqOption do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/UnknownSidekiqOption' => {} } }

  it 'registers an offense for unknown options' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        sidekiq_options priorty: :high
                        ^^^^^^^^^^^^^^ Unknown or unsupported Sidekiq option `priorty` in `sidekiq_options`.
      end
    RUBY
  end

  it 'does not register an offense for allowed options' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        sidekiq_options queue: :critical, retry: 5, backtrace: true
      end
    RUBY
  end
end
