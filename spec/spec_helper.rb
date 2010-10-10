require 'rubygems'
require 'bacon'

Bacon.summary_on_exit

require File.expand_path('../../lib/git-svn-mirror.rb', __FILE__)

require 'fileutils'

def clean!
  FileUtils.rm_rf(TMP)
  FileUtils.mkdir_p(TMP)

  FileUtils.mkdir_p(WORKBENCH_REPO)

  # create empty git repo
  FileUtils.mkdir_p(GIT_REPO)
  Dir.chdir(GIT_REPO) { system "git init > /dev/null 2>&1" }
end

def sh(dir, command)
  result = ""
  Dir.chdir(dir) { result = `#{command}` }
  result.strip
end

def checkout(branch)
  sh GIT_REPO, "git checkout #{branch} > /dev/null 2>&1"
end

def entries
  Dir.entries(GIT_REPO).reject { |x| x[0,1] == '.' }
end

def config(key)
  sh WORKBENCH_REPO, "git config --get #{key}"
end

def author_and_email
  sh(GIT_REPO, "git log -n 1 --format=format:'%an <%ae>'")
end

SPEC_ROOT = File.expand_path('..', __FILE__)
FIXTURES  = File.join(SPEC_ROOT, 'fixtures')
TMP       = File.join(SPEC_ROOT, 'tmp')

WORKBENCH_REPO = File.join(TMP, 'workbench_repo')
SVN_REPO       = File.join(FIXTURES, 'svn_repo')
GIT_REPO       = File.join(TMP, 'git_repo')

AUTHORS_FILE   = File.join(FIXTURES, 'authors.txt')
