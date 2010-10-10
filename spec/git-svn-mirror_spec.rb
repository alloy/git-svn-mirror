require File.expand_path("../spec_helper", __FILE__)

describe "GitSVNMirror" do
  before do
    unless @mirror
      clean!
      @mirror = GitSVNMirror.run(%W{ init --from=file://#{SVN_REPO} --to=#{GIT_REPO} --workbench=#{WORKBENCH_REPO} })
    end
  end

  describe "concerning `init'" do
    it "parses the given arguments" do
      @mirror.from.should == "file://#{SVN_REPO}"
      @mirror.to.should == GIT_REPO
      @mirror.workbench.should == WORKBENCH_REPO
    end

    it "creates a bare workbench repo" do
      config("core.bare").should == "true"
    end

    it "adds an authors file config entry if one is given" do
      config("svn-remote.svn.authorsfile").should.be.empty
      clean!
      GitSVNMirror.run(%W{ init --authors-file='authors.txt' --from=file://#{SVN_REPO} --to=#{GIT_REPO} --workbench=#{WORKBENCH_REPO} })
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
      GitSVNMirror.run(%W{ update #{WORKBENCH_REPO} })
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
