require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ryori"
    gem.summary = %Q{Easy to use, extensible generator and recipes compiler. }
    gem.description = <<-DESCR
      TODO...
    DESCR
    gem.email = "kriss.kowalik@gmail.com"
    gem.homepage = "http://github.com/nu7hatch/ryori"
    gem.authors = ["Kriss 'nu7hatch' Kowalik"]
    gem.add_development_dependency "rspec", "~> 2.0"
    gem.add_development_dependency "mocha", "~> 0.9"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = %q[--colour --backtrace]
end

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rspec_opts = %q[--colour --backtrace]
  t.rcov_opts = %q[--exclude "spec" --text-report]
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Ryori #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
