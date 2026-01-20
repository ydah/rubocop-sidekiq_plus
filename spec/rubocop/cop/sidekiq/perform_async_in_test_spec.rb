# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::PerformAsyncInTest, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/PerformAsyncInTest' => {} } }

  it 'registers an offense for perform_async in spec files' do
    allow(cop).to receive(:processed_source).and_return(
      instance_double(RuboCop::ProcessedSource, file_path: 'spec/jobs/my_job_spec.rb')
    )

    expect_offense(<<~RUBY)
      MyJob.perform_async(user.id)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid perform_async in tests. Use perform_inline or call perform directly.
    RUBY
  end

  it 'does not register an offense outside test files' do
    allow(cop).to receive(:processed_source).and_return(
      instance_double(RuboCop::ProcessedSource, file_path: 'app/jobs/my_job.rb')
    )

    expect_no_offenses(<<~RUBY)
      MyJob.perform_async(user.id)
    RUBY
  end
end
