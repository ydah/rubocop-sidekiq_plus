# frozen_string_literal: true

require 'rubocop'
require 'rubocop-sidekiq_plus'
require 'rubocop/cops_documentation_generator'
require 'yard'

# Monkey patch to normalize Hash formatting regardless of Ruby version
class CopsDocumentationGenerator
  private

  # Override to normalize Hash values to Ruby 3.4+ format
  def format_table_value(val)
    value = formatted_table_value(val)
    value.gsub("#{@base_dir}/", '').rstrip
  end

  def formatted_table_value(val)
    case val
    when Array
      format_array_value(val)
    when Hash
      # Normalize Hash to Ruby 3.4+ format with spaces around =>
      normalize_hash(val)
    else
      wrap_backtick(val.nil? ? '<none>' : val)
    end
  end

  def format_array_value(val)
    return '`[]`' if val.empty?

    val.map { |config| format_table_value(config) }.join(', ')
  end

  def normalize_hash(hash)
    return '`{}`' if hash.empty?

    pairs = hash.map { |key, value| format_hash_pair(key, value) }
    "`{#{pairs.join(', ')}}`"
  end

  def format_hash_pair(key, value)
    formatted_value = value.is_a?(String) ? value.inspect : value.to_s
    return "#{key}: #{formatted_value}" if key.is_a?(Symbol)

    "#{key.inspect} => #{formatted_value}"
  end
end

YARD::Rake::YardocTask.new(:yard_for_generate_documentation) do |task|
  task.files = ['lib/rubocop/cop/**/*.rb']
  task.options = ['--no-output']
end

desc 'Generate docs of all cops departments'
task generate_cops_documentation: :yard_for_generate_documentation do
  generator = CopsDocumentationGenerator.new(
    departments: %w[Sidekiq SidekiqPro SidekiqEnt], plugin_name: 'rubocop-sidekiq_plus'
  )
  generator.call
end

desc 'Syntax check for the documentation comments'
task documentation_syntax_check: :yard_for_generate_documentation do
  require 'parser/ruby25'

  ok = true
  YARD::Registry.load!
  cops = RuboCop::Cop::Registry.global
  cops.each do |cop|
    examples = YARD::Registry.all(:class).find do |code_object|
      next unless RuboCop::Cop::Badge.for(code_object.to_s) == cop.badge

      break code_object.tags('example')
    end

    examples.to_a.each do |example|
      buffer = Parser::Source::Buffer.new('<code>', 1)
      buffer.source = example.text
      parser = Parser::Ruby25.new(RuboCop::AST::Builder.new)
      parser.diagnostics.all_errors_are_fatal = true
      parser.parse(buffer)
    rescue Parser::SyntaxError => e
      path = example.object.file
      puts "#{path}: Syntax Error in an example. #{e}"
      ok = false
    end
  end
  abort unless ok
end
