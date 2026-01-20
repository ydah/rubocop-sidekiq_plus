# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::HugeJobArguments, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/HugeJobArguments' => {} } }

  it 'registers an offense for pluck with many columns' do
    expect_offense(<<~RUBY)
      MyJob.perform_async(User.pluck(:id, :name, :email))
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid passing large arguments to Sidekiq jobs. Pass IDs and load records in the job instead.
    RUBY
  end

  it 'does not register an offense for pluck with few columns' do
    expect_no_offenses(<<~RUBY)
      MyJob.perform_async(User.pluck(:id, :name))
    RUBY
  end

  it 'registers an offense for large array literals' do
    expect_offense(<<~RUBY)
      MyJob.perform_async([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid passing large arguments to Sidekiq jobs. Pass IDs and load records in the job instead.
    RUBY
  end

  it 'registers an offense for large hash literals' do
    expect_offense(<<~RUBY)
      MyJob.perform_async({ a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11 })
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid passing large arguments to Sidekiq jobs. Pass IDs and load records in the job instead.
    RUBY
  end
end
