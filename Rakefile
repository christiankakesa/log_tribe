# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new('spec'.freeze)

task default: :spec

desc 'Generate documentation'.freeze
YARD::Rake::YardocTask.new do |t|
  t.files = %w(lib/**/*.rb - LICENSE.txt).map(&:freeze).freeze
  t.options = %w(--main README.md --no-private --protected).map(&:freeze).freeze
end
