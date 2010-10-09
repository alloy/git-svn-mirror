require 'rubygems'
require 'bacon'

Bacon.summary_on_exit

require File.expand_path('../../lib/git-svn-mirror.rb', __FILE__)

require 'fileutils'

TMP = File.expand_path('../tmp', __FILE__)
FileUtils.rm_rf(TMP)
FileUtils.mkdir_p(TMP)

WORKBENCH_REPO = File.expand_path('../tmp/workbench_repo', __FILE__)
SVN_REPO = File.expand_path('../fixtures/svn_repo', __FILE__)
GIT_REPO = File.expand_path('../tmp/git_repo', __FILE__)

# create empty git repo
FileUtils.mkdir_p(GIT_REPO)
Dir.chdir(GIT_REPO) { system "git init" }
