require File.expand_path("../spec_helper", __FILE__)

relative_path = WORKBENCH_REPO[Dir.pwd.size+1..-1]
INIT_ARGS_WITHOUT_AUTHORS = %W{ init --from=file://#{SVN_REPO} --to=#{GIT_REPO} --workbench=#{relative_path} }

relative_path = AUTHORS_FILE[Dir.pwd.size+1..-1]
INIT_ARGS_WITH_AUTHORS = INIT_ARGS_WITHOUT_AUTHORS.dup
INIT_ARGS_WITH_AUTHORS << "--authors-file=#{relative_path}"

describe "GitSVNMirror" do
  describe "concerning `init'" do
    it "defaults the workbench to the current work dir" do
      clean!
      argv = INIT_ARGS_WITHOUT_AUTHORS.dup
      argv.pop
      _, status = Dir.chdir(WORKBENCH_REPO) { GitSVNMirror.run(argv) }
      status.should == true
      File.should.exist File.join(WORKBENCH_REPO, 'config')
    end

    it "validates if the workbench path exists" do
      clean!
      argv = INIT_ARGS_WITHOUT_AUTHORS.dup
      argv.pop
      argv << "--workbench=/does/not/exist"
      _, status = GitSVNMirror.run(argv)
      status.should == false
      File.should.not.exist File.join(WORKBENCH_REPO, 'config')
    end

    it "adds an authors file config entry if one is given and it exists" do
      clean!

      argv = INIT_ARGS_WITHOUT_AUTHORS.dup
      argv << "--author-file=/does/not/exist.txt"
      _, status = GitSVNMirror.run(argv)
      status.should == false

      _, status = GitSVNMirror.run(INIT_ARGS_WITH_AUTHORS.dup)
      status.should == true
      config("svn.authorsfile").should == File.expand_path("spec/fixtures/authors.txt")
    end

    # only once for the remaining specs
    before do
      unless @mirror
        clean!
        @mirror, @status = GitSVNMirror.run(INIT_ARGS_WITHOUT_AUTHORS.dup)
      end
    end

    it "successfully creates the mirror" do
      @status.should == true
    end

    it "parses the given arguments" do
      @mirror.from.should == "file://#{SVN_REPO}"
      @mirror.to.should == GIT_REPO
      @mirror.workbench.should == WORKBENCH_REPO
    end

    it "creates a bare workbench repo" do
      config("core.bare").should == "true"
    end

    it "configures the SVN remote to fetch trunk, branches, and tags" do
      config("svn-remote.svn.url").should == "file://#{SVN_REPO}"
      config("svn-remote.svn.fetch").should == "trunk:refs/remotes/svn/trunk"
      config("svn-remote.svn.branches").should == "branches/*:refs/remotes/svn/*"
      config("svn-remote.svn.tags").should == "tags/*:refs/remotes/svn/tags/*"
    end

    it "does not by default configure an authors file" do
      config("svn.authorsfile").should.be.empty
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
    def init_and_update(argv)
      GitSVNMirror.run(argv)
      GitSVNMirror.run(%W{ update #{WORKBENCH_REPO} })
    end

    it "updates the authors from the optional authors file" do
      clean!
      init_and_update(INIT_ARGS_WITH_AUTHORS.dup)
      checkout("trunk")
      author_and_email.should == 'Eloy Duran <eloy.de.enige@gmail.com>'
    end

    it "defaults to the current work dir" do
      clean!
      GitSVNMirror.run(INIT_ARGS_WITHOUT_AUTHORS.dup)
      Dir.chdir(WORKBENCH_REPO) do
        _, status = GitSVNMirror.run(%w{ update })
        status.should == true
      end
      checkout "trunk"
      entries.should == %w{ file.txt file2.txt }
    end

    # only once for the remaining specs
    before do
      unless @mirror
        clean!
        @mirror, @status = init_and_update(INIT_ARGS_WITHOUT_AUTHORS.dup)
      end
    end

    it "returns the configuration" do
      @mirror.from.should == "file://#{SVN_REPO}"
      @mirror.to.should == GIT_REPO
      @mirror.workbench.should == WORKBENCH_REPO
    end

    it "syncs the SVN repo to the GIT repo" do
      checkout "trunk"
      entries.should == %w{ file.txt file2.txt }

      checkout "tags/second-commit"
      entries.should == %w{ file.txt file2.txt }

      checkout "first-commit"
      entries.should == %w{ file.txt }
    end

    it "does not try to convert the authors names and emails by default" do
      checkout("trunk")
      author_and_email.should.not == 'Eloy Duran <eloy.de.enige@gmail.com>'
    end

    it "makes sure that after pushing multiple times, it does not include duplicate origin branches" do
      @mirror.update
      sh(GIT_REPO, "git branch -a").should.not.include "origin"
    end
  end
end
