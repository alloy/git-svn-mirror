require 'optparse'

class GitSVNMirror
  attr_accessor :from, :to, :workbench, :authors_file, :silent

  def self.run(argv)
    mirror = new
    status = case argv.shift
             when 'init'   then init(mirror, argv)
             when 'update' then update(mirror, argv)
             else
               puts "Usage: git-svn-mirror [init|update]"
               false
             end
    [mirror, status]
  end

  def self.option_parser(mirror, argv)
    opts = OptionParser.new do |o|
      yield(o)
      o.on('-s', '--silent', 'Silent mode.') { mirror.silent = true }
    end
    opts.parse!(argv)
    opts
  end

  def self.init(mirror, argv)
    opts = option_parser(mirror, argv) do |o|
      o.banner = "Usage: git-svn-mirror init [mandatory options] [options]"
      o.separator "\n  Mandatory options are --from and --to.\n\n"
      o.on('--from URI',          'The location of the SVN repository that is to be mirrored.')                  { |uri| mirror.from = uri }
      o.on('--to URI',            'The location of the GIT repository that is the mirror.')                      { |uri| mirror.to = uri }
      o.on('--workbench PATH',    'The location of the workbench repository. Defaults to the current work dir.') { |wb|  mirror.workbench = wb }
      o.on('--authors-file PATH', 'An optional authors file used to migrate SVN usernames to GIT\'s format.')    { |af|  mirror.authors_file = af }
    end

    if mirror.from && mirror.to
      if !File.exist?(mirror.workbench)
        puts "[!] Given workbench path does not exist."
        false
      else
        if mirror.authors_file && !File.exist?(mirror.authors_file)
          puts "[!] Given authors file does not exist."
          false
        else
          mirror.init
          true
        end
      end
    else
      puts opts
      false
    end
  end

  def self.update(mirror, argv)
    opts = option_parser(mirror, argv) do |o|
      o.banner = "Usage: git-svn-mirror update [options] [workbench1] [workbench2] ..."
      o.separator "\nDefaults to the current work dir if none is given.\n\n"
    end

    if argv.empty?
      mirror.update
    else
      argv.each do |workbench|
        mirror.workbench = workbench
        mirror.update
      end
    end
    true
  end

  def init
    log "* Configuring mirror workbench at `#{workbench}'"
    sh "git init --bare"

    sh "git svn init --stdlayout --prefix=svn/ #{from}"
    sh "git config --add svn.authorsfile '#{authors_file}'" if authors_file

    sh "git remote add origin #{to}"
    sh "git config --add remote.origin.push 'refs/remotes/svn/*:refs/heads/*'"

    fetch
    log "* Running garbage collection"
    sh "git gc"

    log "The mirror workbench has been configured. To push to the remote GIT repo,",
        "and possibly as a cron job, run the following command:",
        "",
        "  $ git-svn-mirror update '#{workbench}'"
  end

  def update
    fetch
    push
  end

  def fetch
    log "* Fetching from SVN repo at `#{from}'"
    sh "git svn fetch"
  end

  def push
    log "* Pushing to GIT repo at `#{to}'"
    sh "git push origin"
  end

  def from
    @from ||= config("svn-remote.svn.url")
  end

  def to
    @to ||= config("remote.origin.url")
  end

  def workbench=(path)
    @workbench = File.expand_path(path)
  end

  def workbench
    @workbench ||= Dir.pwd
  end

  def authors_file=(path)
    @authors_file = File.expand_path(path)
  end

  def log(*str)
    puts("\n#{str.join("\n")}\n\n") unless @silent
  end

  def config(key)
    value = sh("git config --get #{key}", true)
    value unless value.empty?
  end

  def sh(command, capture = false)
    Dir.chdir(workbench) do
      command = "env GIT_DIR='#{workbench}' #{command}"
      command += (@silent ? " > /dev/null 2>&1" : " 1>&2") unless capture
      `#{command}`.strip
    end
  end
end
