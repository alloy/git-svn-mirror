desc "Run the specs"
task :spec do
  sh "ruby spec/git-svn-mirror_spec.rb"
end

task :default => :spec

begin
  require 'rubygems'
  require 'jeweler'
  require File.expand_path('../lib/git-svn-mirror', __FILE__)
  Jeweler::Tasks.new do |s|
    s.name = "git-svn-mirror"
    s.version = GitSVNMirror::VERSION
    s.summary = s.description = "A command-line tool that automates the task of creating a GIT mirror for a SVN repo, and keeping it up-to-date."
    s.email = "eloy.de.enige@gmail.com"
    s.homepage = "http://github.com/alloy/git-svn-mirror"
    s.authors = ["Eloy Duran"]
    s.files.reject! { |file| file =~ /^(\.gitignore|Rakefile|spec)/ }
    s.test_files = []
  end
rescue LoadError
end
