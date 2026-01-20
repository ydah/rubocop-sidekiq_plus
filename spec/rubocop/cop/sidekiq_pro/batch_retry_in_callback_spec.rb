# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::BatchRetryInCallback, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/BatchRetryInCallback' => {} } }

  it 'registers an offense when perform_async is called in on_complete' do
    expect_offense(<<~RUBY)
      class MyCallback
        def on_complete(status, options)
          FinalizeJob.perform_async(options['order_id'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Jobs enqueued in batch callbacks should have retry enabled.
        end
      end
    RUBY
  end

  it 'registers an offense when perform_async is called in on_success' do
    expect_offense(<<~RUBY)
      class MyCallback
        def on_success(status, options)
          NotifyJob.perform_async(options['user_id'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Jobs enqueued in batch callbacks should have retry enabled.
        end
      end
    RUBY
  end

  it 'registers an offense when perform_async is called in on_death' do
    expect_offense(<<~RUBY)
      class MyCallback
        def on_death(status, options)
          AlertJob.perform_async(options['batch_id'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Jobs enqueued in batch callbacks should have retry enabled.
        end
      end
    RUBY
  end

  it 'registers an offense when perform_in is called in callback' do
    expect_offense(<<~RUBY)
      class MyCallback
        def on_complete(status, options)
          DelayedJob.perform_in(5.minutes, options['id'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Jobs enqueued in batch callbacks should have retry enabled.
        end
      end
    RUBY
  end

  it 'registers an offense when perform_at is called in callback' do
    expect_offense(<<~RUBY)
      class MyCallback
        def on_complete(status, options)
          ScheduledJob.perform_at(Time.now + 1.hour, options['id'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Jobs enqueued in batch callbacks should have retry enabled.
        end
      end
    RUBY
  end

  it 'does not register an offense for non-callback methods' do
    expect_no_offenses(<<~RUBY)
      class RegularClass
        def some_method(status, options)
          SomeJob.perform_async(1)
        end
      end
    RUBY
  end

  it 'does not register an offense for methods with different signatures' do
    expect_no_offenses(<<~RUBY)
      class MyClass
        def on_complete(single_arg)
          SomeJob.perform_async(1)
        end
      end
    RUBY
  end

  it 'does not register an offense when no jobs are enqueued' do
    expect_no_offenses(<<~RUBY)
      class MyCallback
        def on_complete(status, options)
          Rails.logger.info("Batch completed")
        end
      end
    RUBY
  end
end
