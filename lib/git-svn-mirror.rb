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
    sh "git svn init --stdlayout #{@from}"
    sh "git remote add origin #{@to}"
  end

  def svn_repo_name
    File.basename(@from)
  end

  def sh(command)
    Dir.chdir(@workbench) { system("env GIT_DIR='#{@workbench}' #{command}") }
  end
end
