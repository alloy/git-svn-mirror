git-svn-mirror
--------------

A command-line tool that automates the task of creating a GIT mirror for a SVN
repo, and keeping it up-to-date.

Why
---

Figuring this stuff out is a pain in the bum, in my opinion, and its probably
not even done yet. So please do contribute! Also, if I would keep doing this by
hand, I would forget how to do it, a few weeks down the line.

Install
-------

This tool is packaged as a Ruby Gem, install it by running the following:

	$ gem install git-svn-mirror

Configure the ‘workbench’
-------------------------

To mirror a SVN repo, first the local ‘workbench’ repo has to be configured.
This ‘workbench’ is the GIT repo where the SVN revisions will be stored and
from where these revisions will be pushed to the remote mirror GIT repo.

Start by creating the directory:

	$ mkdir -p /path/to/workbench

Then initialize the ‘workbench’:

	$ cd /path/to/workbench
	$ git-svn-mirror init --from=http://svn-host/repo_root --to=git@git-host:user/mirror.git

This will create a ‘bare’ GIT repo, configure the SVN and GIT remotes, fetch
the revisions from the SVN remote, and compact the ‘workbench’ by running the
GIT garbage collector.

It can often be handy to supply an authors file, with the <tt>--authors-file</tt>
option, which is used to migrate user names to GIT names and email addresses.
The entries in this file should look like:

	svn-user-name = User Name <user@example.com>

Update mirror
-------------

To push the latest changes from the SVN repo to the GIT repo, run the following
command from the ‘workbench’ repo:

	$ git-svn-mirror update

Or by specifying the path(s) to one or more ‘workbench’ repos:

	$ git-svn-mirror update /path/to/workbench1 /path/to/workbench2

You will probably normally not want to perform this step by hand. You can solve
this by adding this command as a cron job, in which case you can silence the
tool with the <tt>--silent</tt> option.

‘init’ help banner
----------------

	Usage: git-svn-mirror init [mandatory options] [options]
	
	  Mandatory options are --from and --to.
	
	    --from URI                   The location of the SVN repository that is to be mirrored.
	    --to URI                     The location of the GIT repository that is the mirror.
	    --workbench PATH             The location of the workbench repository. Defaults to the current work dir.
	    --authors-file PATH          An optional authors file used to migrate SVN usernames to GIT's format.
	-s, --silent                     Silent mode.

‘update’ help banner
--------------------

	Usage: git-svn-mirror update [options] [workbench1] [workbench2] ...
	
	  Defaults to the current work dir if none is given.
	
	-s, --silent                     Silent mode.

Contributing
------------

Once you've made your great commits:

1. [Fork][fk] git-svn-mirror
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create an [Issue][is] with a link to your branch
5. That’s it!

License In Three Lines (LITL)
-----------------------------

	© Eloy Duran <eloy.de.enige@gmail.com>
	You may use these works without restrictions. As long as this paragraph is
	included. The work is provided “as is”, without warranty of any kind.

[fk]: http://help.github.com/forking/
[is]: http://github.com/alloy/git-svn-mirror/issues
