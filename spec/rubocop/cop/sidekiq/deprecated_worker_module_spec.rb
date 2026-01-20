# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::DeprecatedWorkerModule, :config do
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
