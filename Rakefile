# frozen_string_literal: true
require 'jeweler'

VERSION_FILE = File.expand_path('../VERSION', __FILE__)
VERSION_STRING = File.read(VERSION_FILE).strip
Jeweler::Tasks.new do |gem|
  gem.name = 'opengov-util'
  gem.summary = 'OpenGov Ruby Utilities'
  gem.description = 'Useful utilities for Ruby'
  gem.email = ['trodriguez@opengov.com']
  gem.homepage = 'https://github.com/OpenGov/og-ruby-utils'
  gem.authors = ['Tim Rodriguez']
  gem.required_ruby_version = '>= 2.0.0'
  gem.license = 'MIT License'
  gem.version = VERSION_STRING
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end
rescue LoadError
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
end

desc 'Run Rubocop Linter'
task :rubocop do
  sh 'rubocop .'
end

task default: [:rubocop, :spec]
