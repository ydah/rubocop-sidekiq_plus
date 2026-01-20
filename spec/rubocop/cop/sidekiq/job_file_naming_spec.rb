# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::JobFileNaming, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/JobFileNaming' => {} } }

  it 'registers an offense when file name does not match class name' do
    allow(cop).to receive(:processed_source).and_return(
      instance_double(RuboCop::ProcessedSource, file_path: 'app/jobs/send_email_worker.rb')
    )

    expect_offense(<<~RUBY)
      class SendEmailJob
      ^^^^^ Job file name should match the class name.
        include Sidekiq::Job
      end
    RUBY
  end

  it 'does not register an offense when file name matches class name' do
    allow(cop).to receive(:processed_source).and_return(
      instance_double(RuboCop::ProcessedSource, file_path: 'app/jobs/send_email_job.rb')
    )

    expect_no_offenses(<<~RUBY)
      class SendEmailJob
        include Sidekiq::Job
      end
    RUBY
  end
end
