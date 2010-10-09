require 'rubygems'
require 'bacon'

Bacon.summary_on_exit

require File.expand_path('../../lib/git-svn-mirror.rb', __FILE__)

require 'fileutils'

def clean!
  FileUtils.rm_rf(TMP)
  FileUtils.mkdir_p(TMP)

  # create empty git repo
  FileUtils.mkdir_p(GIT_REPO)
  Dir.chdir(GIT_REPO) { system "git init > /dev/null 2>&1" }
end

TMP = File.expand_path('../tmp', __FILE__)

WORKBENCH_REPO = File.expand_path('../tmp/workbench_repo', __FILE__)
SVN_REPO = File.expand_path('../fixtures/svn_repo', __FILE__)
GIT_REPO = File.expand_path('../tmp/git_repo', __FILE__)
