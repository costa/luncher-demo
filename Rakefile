require 'app'  # This may seem weird, but I don't see too much a problem with it
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new

namespace :db do
  task :migrate do
    DataMapper.auto_migrate!
  end
end

task :default => :spec
