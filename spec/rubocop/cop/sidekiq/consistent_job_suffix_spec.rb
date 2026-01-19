# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::ConsistentJobSuffix do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/ConsistentJobSuffix' => {} } }

  it 'registers an offense when suffix does not match' do
    expect_offense(<<~RUBY)
      class ProcessPaymentWorker
      ^^^^^ Use `Job` suffix for Sidekiq job class names.
        include Sidekiq::Job
      end
    RUBY
  end

  context 'when EnforcedSuffix is Worker' do
    let(:cop_config) { { 'Sidekiq/ConsistentJobSuffix' => { 'EnforcedSuffix' => 'Worker' } } }

    it 'does not register an offense for Worker suffix' do
      expect_no_offenses(<<~RUBY)
        class ProcessPaymentWorker
          include Sidekiq::Job
        end
      RUBY
    end
  end
end
