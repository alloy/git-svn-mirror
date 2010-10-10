require "optparse"

class GitSVNMirror
  attr_accessor :from, :to, :workbench, :authors_file

  def self.run(argv)
    mirror = new
    case argv.shift
    when 'init'
      OptionParser.new do |opt|
        opt.on('--from URI', 'The location of the SVN repository that is to be mirrored.') { |uri| mirror.from = uri }
        opt.on('--to URI',   'The location of the GIT repository that is the mirror.') { |uri| mirror.to = uri }
        opt.on('--workbench PATH', 'The location of the workbench repository from where the mirroring will occur') { |wb| mirror.workbench = wb }
        opt.on('--authors-file PATH', 'An optional authors file used to migrate SVN usernames to GIT’s format') { |af| mirror.authors_file = af }
      end.parse!(argv)
      mirror.init
    when 'update'
      argv.each do |workbench|
        mirror.workbench = workbench
        mirror.update
      end
    end
    mirror
  end

  def init
    sh "git init --bare"
    sh "git svn init --stdlayout --prefix=svn/ #{@from}"
    sh "git config --add svn-remote.svn.authorsfile '#{@authors_file}'" if @authors_file
    sh "git remote add origin #{@to}"
    sh "git config --add remote.origin.push 'refs/remotes/svn/*:refs/heads/*'"

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
    sh "git push origin"
  end

  def sh(command)
    Dir.chdir(@workbench) { system("env GIT_DIR='#{@workbench}' #{command} > /dev/null 2>&1") }
  end
end
