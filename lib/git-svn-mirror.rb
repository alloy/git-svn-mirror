require "optparse"

class GitSVNMirror
  attr_reader :from, :to, :workbench

  def init(argv)
    OptionParser.new do |opt|
      opt.on('--from URI', 'The location of the SVN repository that is to be mirrored.') { |uri| @from = uri }
      opt.on('--to URI',   'The location of the GIT repository that is the mirror.')     { |uri| @to = uri }
    end.parse!(argv)

    @workbench = argv.shift

    sh "git init --bare"
    sh "git svn init --stdlayout --prefix=svn/ #{@from}"
    sh "git remote add origin #{@to}"

    fetch
    sh "git gc"
  end

  def update
    fetch
    push
  end

  def fetch
    sh "git svn fetch"
  end

  def push
    sh "git push origin 'refs/remotes/svn/*:refs/heads/*'"
  end

  def svn_repo_name
    File.basename(@from)
  end

  def sh(command)
    Dir.chdir(@workbench) { system("env GIT_DIR='#{@workbench}' #{command} > /dev/null 2>&1") }
  end
end
