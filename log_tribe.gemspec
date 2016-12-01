# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_tribe/version'

Gem::Specification.new do |spec|
  spec.name          = 'log_tribe'
  spec.version       = LogTribe::VERSION
  spec.authors       = ['Christian Kakesa']
  spec.email         = ['christian.kakesa@gmail.com']

  spec.summary       = 'Write logs messages to multiple destinations.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/fenicks/log_tribe'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7', '>= 1.7.0'
  spec.add_development_dependency 'rake', '~> 0'
  spec.add_development_dependency 'rubocop', '~> 0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'simplecov', '~> 0'
  spec.add_development_dependency 'coveralls', '~> 0'
  spec.add_development_dependency 'memory_profiler', '~> 0' if RUBY_VERSION >= '2.1.0'
  spec.add_development_dependency 'yard', '~> 0'
end
