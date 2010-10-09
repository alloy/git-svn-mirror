require File.expand_path("../spec_helper", __FILE__)

EXPECTED_CONFIG = <<EOS
[core]
	repositoryformatversion = 0
	filemode = true
	bare = true
	ignorecase = true
	autocrlf = false
[svn-remote "svn"]
	url = file://#{SVN_REPO}
	fetch = trunk:refs/remotes/svn/trunk
	branches = branches/*:refs/remotes/svn/*
	tags = tags/*:refs/remotes/svn/tags/*
[remote "origin"]
	url = #{GIT_REPO}
	fetch = +refs/heads/*:refs/remotes/origin/*
EOS

describe "GitSVNMirror" do
  before do
    unless @mirror
      clean!
      FileUtils.mkdir_p(WORKBENCH_REPO)
      @mirror = GitSVNMirror.new
      @mirror.init(%W{ --from=file://#{SVN_REPO} --to=#{GIT_REPO} #{WORKBENCH_REPO}})
    end
  end

  describe "concerning `init'" do
    it "parses the given arguments" do
      @mirror.from.should == "file://#{SVN_REPO}"
      @mirror.to.should == GIT_REPO
      @mirror.workbench.should == WORKBENCH_REPO
    end

    it "returns the name of the SVN repo" do
      @mirror.svn_repo_name.should == File.basename(SVN_REPO)
    end

    it "initializes the workbench repo" do
      config = File.read(File.join(WORKBENCH_REPO, 'config'))
      config.should == EXPECTED_CONFIG
    end

    it "performs an update afterwards" do
      checkout "trunk"
      Dir.entries(GIT_REPO).size.should > 3 # [".", "..", ".git"]
    end
  end

  describe "concerning `update'" do
    before do
      @mirror.update
    end

    it "syncs the SVN repo to the GIT repo" do
      checkout "trunk"
      entries.should == %w{ file.txt file2.txt }

      checkout "tags/second-commit"
      entries.should == %w{ file.txt file2.txt }

      checkout "first-commit"
      entries.should == %w{ file.txt }
    end

    it "makes sure that after pushing multiple times, it does not include duplicate origin branches" do
      @mirror.update
      sh_in_git_repo("git branch -a").should.not.include "origin"
    end
  end
end
