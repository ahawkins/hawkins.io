---
layout: post
title: "Introducing Vagrant Workstation"
---

I've finally completed an idea that's been kicking around my head for
a while. Professionally & personally I ship software as docker images
as much as possible. This means the development environment in general
is quite straight forward: install docker and few other utils. This
worked well for a while, but we had been using the "one vm per
project" model. This worked in the beginning but it didn't scale once
we have ~15 projects each with larger memory needs. Since all the
machines were generally the same it was possible to collapse them into
a single VM. My friend and coworker [Terje Larsen][] created `vrun`
([source][vrun]). This util makes `vagrant ssh -c` fast by caching the
`vagrant-ssh` config. So we had nice commands to make executing things
from our host to VM. Everything worked because the project lived
inside `/vagrant`. However, what happened when there were multiple
projects inside the same VM? There was no orchestration.

Enter [vagrant-workstation][github]. This project is the
orchestrator. It makes running per-project commands easy in a VM
containing multiple projects trivial. My general setups looks
something like this. I clone all the repos into `~/code.`. I start the
workstation with `/~code` mounted to `/projects`. Now I can navigate
to anywhere inside `~/code` on my host and execute `workstation run
foo` and `foo` is executed in the VM at the appropriate path. This
works out well.

There's also another handy feature. Say you're working on project A
and you need to do something in Project B. You don't really want to
switch directories, you just want to run a command. We have this use
case because our deploy tool reads config from `$PWD`. So the common
case was, I'm in project A and I need to see logs from project A. Run
`workstation run -p project-a` and it will fuzzy match projects. No
need to switch directories for one off commands.

Other uses also evolved. I mentioned earlier that most of the work is
done using docker. This means `docker` is executed oftenly inside the
VM. This spawned a bunch of shell aliases for things like `vdocker`
which is short for `vrun docker`. This worked well in practice but not
all team members had these nice things configured. One team member
would pair with another and ask "how did you do that?". So
`vagrant-workstation` also supports custom commands that can be kept
in source control and are also shell independent (because not everyone
uses the same shell). Here's an example:

	$ echo "make test" > .workstation/commands/test
	$ workstation test # => workstation run make test

This is my favorite feature because it's easy to put all common
workflow commands in an easy accessible place and they're run quickly!

So checkout the source on [github][] and let me know what you think.

[github]: https://github.com/ahawkins/vagrant-workstation
[Terje Larsen]: https://github.com/terlar
[vrun]: https://github.com/terlar/dotfiles/blob/master/local/bin/vrun
