require File.expand_path("../spec_helper", __FILE__)

describe "GitSVNMirror, concerning `init'" do

  # before all
  FileUtils.mkdir_p(WORKBENCH_REPO)
  @mirror = GitSVNMirror.new
  @mirror.init(%W{ --from=file://#{SVN_REPO} --to=#{GIT_REPO} #{WORKBENCH_REPO}})

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
    config.should == <<EOS
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
  end
end
