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
      @mirror = GitSVNMirror.new
      @mirror.init(%W{ --from=file://#{SVN_REPO} --to=#{GIT_REPO} #{WORKBENCH_REPO} })
    end
  end

  describe "concerning `init'" do
    it "parses the given arguments" do
      @mirror.from.should == "file://#{SVN_REPO}"
      @mirror.to.should == GIT_REPO
      @mirror.workbench.should == WORKBENCH_REPO
    end

    #it "initializes the workbench repo" do
      #config = File.read(File.join(WORKBENCH_REPO, 'config'))
      #config.should == EXPECTED_CONFIG
    #end

    it "creates a bare workbench repo" do
      config("core.bare").should == "true"
    end

    it "adds an authors file config entry if one is given" do
      config("svn-remote.svn.authorsfile").should.be.empty
      clean!
      @mirror.init(%W{ --authors-file='authors.txt' --from=file://#{SVN_REPO} --to=#{GIT_REPO} #{WORKBENCH_REPO} })
      config("svn-remote.svn.authorsfile").should == "authors.txt"
    end

    it "configures the SVN remote to fetch trunk, branches, and tags" do
      config("svn-remote.svn.url").should == "file://#{SVN_REPO}"
      config("svn-remote.svn.fetch").should == "trunk:refs/remotes/svn/trunk"
      config("svn-remote.svn.branches").should == "branches/*:refs/remotes/svn/*"
      config("svn-remote.svn.tags").should == "tags/*:refs/remotes/svn/tags/*"
    end

    it "configures the GIT remote" do
      config("remote.origin.url").should == GIT_REPO
      config("remote.origin.push").should == "refs/remotes/svn/*:refs/heads/*"
    end

    it "performs a fetch afterwards, but does not push yet" do
      branches = sh(WORKBENCH_REPO, 'git branch -a')
      branches.should.include "remotes/svn/trunk"
      branches.should.include "remotes/svn/first-commit"
      branches.should.include "remotes/svn/tags/second-commit"

      checkout "trunk"
      entries.should.be.empty
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
      sh(GIT_REPO, "git branch -a").should.not.include "origin"
    end
  end
end
