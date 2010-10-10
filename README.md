# git-svn-mirror

A command-line tool that automates the task of creating a GIT mirror of a SVN
repo, and keeping it up-to-date.

## install

This tool is packaged as a Ruby Gem, install it by running the following:

  $ gem install git-svn-mirror

## Usage

### Configure the mirror workbench

To mirror a SVN repo, first the local 'workbench' repo has to be configured.

Start by creating the directory:

  $ mkdir -p /path/to/workbench

Then initialize the 'workbench':

  $ cd /path/to/workbench
  $ git-svn-mirror init --from=http://svn-host/repo_root --to=git@git-host:user/mirror.git

This will create a `bare' GIT repo, configure the SVN and GIT remotes, fetch
the revisions from the SVN remote, and compact the `workbench' by running the
GIT garbage collector.

It can often be handy to supply an authors file which is used to migrate user
names to GIT names and email addresses. See the <tt>--authors-file</tt> option.

### Update mirror

To push the latest changes from the SVN repo to the GIT repo, run the following
command from the `workbench' repo:

  $ git-svn-mirror update

Or by specifying the path(s) to one or more `workbench' repos:

  $ git-svn-mirror update /path/to/workbench1 /path/to/workbench2

You will probably normally not want to perform this step by hand. You can solve
this by adding this command as a cron job, in which case you can silence the
tool with the <tt>--silent</tt> option.

## Help banners

### init

  Usage: git-svn-mirror init [mandatory options] [options]

    Mandatory options are --from and --to.

          --from URI                   The location of the SVN repository that is to be mirrored.
          --to URI                     The location of the GIT repository that is the mirror.
          --workbench PATH             The location of the workbench repository. Defaults to the current work dir.
          --authors-file PATH          An optional authors file used to migrate SVN usernames to GIT's format.
      -s, --silent                     Silent mode.

### update

  Usage: git-svn-mirror update [options] [workbench1] [workbench2] ...

    Defaults to the current work dir if none is given.

      -s, --silent                     Silent mode.

## License In Three Lines (LITL)

  Copyright 2010 Eloy Duran <eloy.de.enige@gmail.com>
  You may use these works, 'as is', for anything.
  If you include this plus copyright notice.
  But without warranty.
