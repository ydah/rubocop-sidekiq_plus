# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::DeprecatedWorkerModule do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/DeprecatedWorkerModule' => {} } }

  it 'registers an offense for Sidekiq::Worker includes' do
    expect_offense(<<~RUBY)
      class MyWorker
        include Sidekiq::Worker
        ^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq::Worker is deprecated. Use Sidekiq::Job instead.
      end
    RUBY

    expect_correction(<<~RUBY)
      class MyWorker
        include Sidekiq::Job
      end
    RUBY
  end
end
