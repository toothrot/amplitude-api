# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts "Unable to load rspec. Have you run `bundle install`?"
end

task(:default).clear
task default: ["rubocop:auto_correct", :spec]
