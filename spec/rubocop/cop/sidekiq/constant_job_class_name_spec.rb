# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::ConstantJobClassName, :config do
  context 'with dynamic class names' do
    it 'registers an offense for variable receiver' do
      expect_offense(<<~RUBY)
        job_class.perform_async(args)
        ^^^^^^^^^ Use a constant class name for Sidekiq jobs. Dynamic job class names are harder to trace and may be insecure.
      RUBY
    end

    it 'registers an offense for constantize' do
      expect_offense(<<~RUBY)
        job_name.constantize.perform_async(args)
        ^^^^^^^^^^^^^^^^^^^^ Use a constant class name for Sidekiq jobs. Dynamic job class names are harder to trace and may be insecure.
      RUBY
    end

    it 'registers an offense for string constantize' do
      expect_offense(<<~RUBY)
        "MyJob".constantize.perform_async(args)
        ^^^^^^^^^^^^^^^^^^^ Use a constant class name for Sidekiq jobs. Dynamic job class names are harder to trace and may be insecure.
      RUBY
    end

    it 'registers an offense for perform_in' do
      expect_offense(<<~RUBY)
        job_class.perform_in(1.hour, args)
        ^^^^^^^^^ Use a constant class name for Sidekiq jobs. Dynamic job class names are harder to trace and may be insecure.
      RUBY
    end

    it 'registers an offense for perform_at' do
      expect_offense(<<~RUBY)
        job_class.perform_at(Time.now, args)
        ^^^^^^^^^ Use a constant class name for Sidekiq jobs. Dynamic job class names are harder to trace and may be insecure.
      RUBY
    end
  end

  context 'with constant class names' do
    it 'does not register an offense for simple constant' do
      expect_no_offenses(<<~RUBY)
        MyJob.perform_async(args)
      RUBY
    end

    it 'does not register an offense for namespaced constant' do
      expect_no_offenses(<<~RUBY)
        MyModule::MyJob.perform_async(args)
      RUBY
    end

    it 'does not register an offense for deeply nested constant' do
      expect_no_offenses(<<~RUBY)
        MyApp::Jobs::SendEmail.perform_async(args)
      RUBY
    end

    it 'does not register an offense for top-level constant' do
      expect_no_offenses(<<~RUBY)
        ::MyJob.perform_async(args)
      RUBY
    end
  end
end
