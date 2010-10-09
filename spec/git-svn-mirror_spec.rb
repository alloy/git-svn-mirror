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
	fetch = trunk:refs/remotes/trunk
	branches = branches/*:refs/remotes/*
	tags = tags/*:refs/remotes/tags/*
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
  end

  describe "concerning `update'" do
    before do
      @mirror.update
    end

    def checkout(branch)
      Dir.chdir(GIT_REPO) { system "git checkout #{branch} > /dev/null 2>&1" }
    end

    def entries
      Dir.entries(GIT_REPO).reject { |x| x[0,1] == '.' }
    end

    it "does not by default alias master to trunk" do
      checkout "master"
      entries.should.be.empty
    end

    it "syncs the SVN repo to the GIT repo" do
      checkout "trunk"
      entries.should == %w{ file.txt file2.txt }

      checkout "tags/second-commit"
      entries.should == %w{ file.txt file2.txt }

      checkout "first-commit"
      entries.should == %w{ file.txt }
    end

    it "optionally aliases master to trunk" do
      @mirror.update(true)
      checkout "master"
      entries.should == %w{ file.txt file2.txt }
    end
  end
end
