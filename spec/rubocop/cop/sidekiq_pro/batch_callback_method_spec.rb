# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::BatchCallbackMethod do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/BatchCallbackMethod' => {} } }

  it 'registers an offense when callback method name is `complete` with 2 args' do
    expect_offense(<<~RUBY)
      class MyCallback
        def complete(status, options)
            ^^^^^^^^ Batch callback method should be named `on_complete`, not `complete`.
        end
      end
    RUBY
  end

  it 'registers an offense when callback method name is `success` with 2 args' do
    expect_offense(<<~RUBY)
      class MyCallback
        def success(status, options)
            ^^^^^^^ Batch callback method should be named `on_success`, not `success`.
        end
      end
    RUBY
  end

  it 'registers an offense when callback method name is `death` with 2 args' do
    expect_offense(<<~RUBY)
      class MyCallback
        def death(status, options)
            ^^^^^ Batch callback method should be named `on_death`, not `death`.
        end
      end
    RUBY
  end

  it 'does not register an offense when callback method name is correct' do
    expect_no_offenses(<<~RUBY)
      class MyCallback
        def on_complete(status, options)
        end
      end
    RUBY
  end

  it 'does not register an offense for method with different argument count' do
    expect_no_offenses(<<~RUBY)
      class RegularClass
        def complete(something)
        end
      end
    RUBY
  end

  it 'does not register an offense for unrelated complete method' do
    expect_no_offenses(<<~RUBY)
      class Task
        def complete
          @completed = true
        end
      end
    RUBY
  end
end
