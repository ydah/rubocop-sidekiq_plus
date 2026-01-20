# frozen_string_literal: true

require 'open3'

require 'bundler'
require 'bundler/gem_tasks'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Dir['tasks/**/*.rake'].each { |t| load t }

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run RuboCop over this gem'
RuboCop::RakeTask.new(:internal_investigation)

desc 'Build config/default.yml'
task :build_config do
  require 'yard'

  require 'rubocop-sidekiq_plus'
  require 'rubocop/sidekiq/config_formatter'
  require 'rubocop/sidekiq/description_extractor'

  cop_paths = [
    File.join('lib', 'rubocop', 'cop', 'sidekiq', '*.rb'),
    File.join('lib', 'rubocop', 'cop', 'sidekiq_pro', '*.rb'),
    File.join('lib', 'rubocop', 'cop', 'sidekiq_ent', '*.rb')
  ].flat_map { |path| Dir[path] }
  # Due to YARD's sensitivity to file require order (as of 0.9.25),
  # we have to prepend the list with our base cops.
  # Otherwise, cop's parent class for cops loaded before our base cop class
  # are detected as RuboCop::Cop::Base, and that complicates the detection
  # of their relation with RuboCop RSpec.
  base_cop_paths = [
    File.join('lib', 'rubocop', 'cop', 'sidekiq', 'base.rb'),
    File.join('lib', 'rubocop', 'cop', 'sidekiq_pro', 'base.rb'),
    File.join('lib', 'rubocop', 'cop', 'sidekiq_ent', 'base.rb')
  ]
  cop_paths -= base_cop_paths
  YARD::Tags::Library.define_tag('Cop Safety Information', :safety)
  YARD.parse(base_cop_paths + cop_paths, [])

  descriptions =
    RuboCop::Sidekiq::DescriptionExtractor.new(YARD::Registry.all(:class)).to_h
  current_config = if Psych::VERSION >= '4.0.0' # RUBY_VERSION >= '3.1.0'
                     YAML.unsafe_load_file('config/default.yml')
                   else
                     YAML.load_file('config/default.yml')
                   end
  current_config ||= {}

  File.write(
    'config/default.yml',
    RuboCop::Sidekiq::ConfigFormatter.new(current_config, descriptions).dump
  )
end

desc 'Confirm config/default.yml is up to date'
task confirm_config: :build_config do
  _, stdout, _, process =
    Open3.popen3('git diff --exit-code config/default.yml')

  raise <<~ERROR unless process.value.success?
    default.yml is out of sync:

    #{stdout.read}
    Please run `rake build_config`
  ERROR
end

desc 'Confirm documentation is up to date'
task confirm_documentation: :generate_cops_documentation do
  stdout, _stderr, status =
    Open3.capture3('git diff --exit-code docs/')

  unless status.success?
    warn 'Documentation is out of sync:'
    warn stdout
    warn 'Please run `rake generate_cops_documentation` ' \
         'and add docs/ to the commit.'
    exit 1
  end
end

task default: %i[build_config spec
                 internal_investigation
                 confirm_config
                 documentation_syntax_check
                 confirm_documentation]

desc 'Generate a new cop template'
task :new_cop, [:cop] do |_task, args|
  require 'rubocop'
  require_relative 'lib/rubocop/rspec/cop/generator'

  cop_name = args.fetch(:cop) do
    warn "usage: bundle exec rake 'new_cop[Department/Name]'"
    exit!
  end

  generator = RuboCop::RSpec::Cop::Generator.new(cop_name)
  generator.write_source
  generator.write_spec
  generator.inject_require(root_file_path: 'lib/rubocop/cop/rspec_cops.rb')
  generator.inject_config

  puts generator.todo
end
