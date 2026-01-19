# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::PerformInline do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }

  context 'when AllowedInTests is true (default)' do
    let(:cop_config) do
      { 'Sidekiq/PerformInline' => { 'AllowedInTests' => true } }
    end

    context 'in production code' do
      before do
        allow(cop).to receive(:processed_source).and_return(
          instance_double(RuboCop::ProcessedSource, file_path: 'app/services/user_service.rb')
        )
      end

      it 'registers an offense for perform_inline' do
        expect_offense(<<~RUBY)
          MyJob.perform_inline(user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `perform_inline` in production code. Use `perform_async` instead.
        RUBY
      end
    end

    context 'in spec file' do
      before do
        allow(cop).to receive(:processed_source).and_return(
          instance_double(RuboCop::ProcessedSource, file_path: 'spec/jobs/my_job_spec.rb')
        )
      end

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          MyJob.perform_inline(user.id)
        RUBY
      end
    end

    context 'in test file' do
      before do
        allow(cop).to receive(:processed_source).and_return(
          instance_double(RuboCop::ProcessedSource, file_path: 'test/jobs/my_job_test.rb')
        )
      end

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          MyJob.perform_inline(user.id)
        RUBY
      end
    end
  end

  context 'when AllowedInTests is false' do
    let(:cop_config) do
      { 'Sidekiq/PerformInline' => { 'AllowedInTests' => false } }
    end

    context 'in spec file' do
      before do
        allow(cop).to receive(:processed_source).and_return(
          instance_double(RuboCop::ProcessedSource, file_path: 'spec/jobs/my_job_spec.rb')
        )
      end

      it 'registers an offense' do
        expect_offense(<<~RUBY)
          MyJob.perform_inline(user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `perform_inline` in production code. Use `perform_async` instead.
        RUBY
      end
    end
  end
end
