# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::JobFileLocation, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/JobFileLocation' => {} } }

  it 'registers an offense when job is outside allowed directories' do
    allow(cop).to receive(:processed_source).and_return(
      instance_double(RuboCop::ProcessedSource, file_path: 'app/models/send_email_job.rb')
    )

    expect_offense(<<~RUBY)
      class SendEmailJob
      ^^^^^ Place Sidekiq job classes under app/jobs or app/workers.
        include Sidekiq::Job
      end
    RUBY
  end

  it 'does not register an offense when job is under app/jobs' do
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
