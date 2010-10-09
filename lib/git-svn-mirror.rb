require "optparse"

class GitSVNMirror
  attr_reader :from, :to, :workbench

  def init(argv)
    OptionParser.new do |opt|
      opt.on('--from URI', 'The location of the SVN repository that is to be mirrored.') { |uri| @from = uri }
      opt.on('--to URI',   'The location of the GIT repository that is the mirror.')     { |uri| @to = uri }
    end.parse!(argv)
    @workbench = argv.shift
  end

  def svn_repo_name
    File.basename(@from)
  end
end
