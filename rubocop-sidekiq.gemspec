# frozen_string_literal: true

require_relative 'lib/rubocop/sidekiq/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-sidekiq_plus'
  spec.version = RuboCop::Sidekiq::VERSION
  spec.authors = ['Yudai Takada']
  spec.email = ['t.yudai92@gmail.com']

  spec.summary = 'Code style checking for Sidekiq'
  spec.description = 'A RuboCop extension focused on enforcing Sidekiq best practices and coding conventions.'
  spec.homepage = 'https://github.com/ydah/rubocop-sidekiq_plus'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::Sidekiq::Plugin'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['config/**/*', 'lib/**/*', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '~> 1.81'
end
