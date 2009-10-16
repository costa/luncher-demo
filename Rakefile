require 'rubygems'
require 'app'  # This may seem weird, but I don't see too much a problem with it
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
# TODO  DataMapper.setup ...
  t.rcov = true
end

namespace :db do
  task :migrate do
    DataMapper.auto_migrate!
  end
end

task :setup do
  puts "Setting up the database"
  if ENV['DATABASE_URL']
    puts "Using \$DATABASE_URL=#{ENV['DATABASE_URL']}, not much to do, yeah?!"
  elsif File.exist? 'var'
    raise "ERROR: Please remove/remap 'var' to start afresh!"
  else
    Dir.mkdir 'var'
    puts "Created new 'var'"
  end
  Rake::Task['db:migrate'].invoke
end

task :demo => [:spec, :setup] do
  eval(File.read('demo/data.rb')).each { |m| m.save }
end

task :default => :spec
