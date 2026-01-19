# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::DeprecatedDefaultWorkerOptions do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/DeprecatedDefaultWorkerOptions' => {} } }

  it 'registers an offense for default_worker_options assignment' do
    expect_offense(<<~RUBY)
      Sidekiq.default_worker_options = { retry: 5 }
              ^^^^^^^^^^^^^^^^^^^^^^ Sidekiq.default_worker_options is deprecated. Use Sidekiq.default_job_options instead.
    RUBY

    expect_correction(<<~RUBY)
      Sidekiq.default_job_options = { retry: 5 }
    RUBY
  end

  it 'registers an offense for default_worker_options access' do
    expect_offense(<<~RUBY)
      Sidekiq.default_worker_options[:retry]
              ^^^^^^^^^^^^^^^^^^^^^^ Sidekiq.default_worker_options is deprecated. Use Sidekiq.default_job_options instead.
    RUBY

    expect_correction(<<~RUBY)
      Sidekiq.default_job_options[:retry]
    RUBY
  end
end
