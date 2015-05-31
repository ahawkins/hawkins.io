---
title: "Why I use Make"
layout: post
---

I've changed many things in my software development workflow over the
past year or so. I've tweeted about bits and parts of it. There is one
thing change that stands out above all else. I started to use make and
it changed everything about how I build and test my software.

It all started by using docker exclusively. This required a new
workflow that I hadn't encountered before. I needed a binary based
tool (read: no language stack required), could map files to other
files (e.g. these files are used in this `Dockerfile`), and could run
arbitrary commands as part of the wider development workflow. I also
wanted something simple so I could create a similar development
experience across all projects (e.g. there is a similar workflow for
building the project and running its tests). Naturally this is a
solved problem. Make solved it some 30 years ago.

Make is a tool for building projects--most commonly for compiled
languages like C. The `Makefile` declares the rules for producing
files and dependencies between files. For example you can have a rule
that `*.c` should produce `*.o` to create a complex graph. Make also
provides functionality to execute arbitrary tasks that do not produce
any files (e.g `make install`). Together make has enough proven
functionality to handle most projects.

Changes happened slowly. First I needed something to handle building
multiple docker images. This was before docker introduced `docker
build -f`. Turns out with a pattern rule and symlinks solved it
easily. `make images/app` would take the appropriate file from
`dockerfiles/app` and coordinate the process in the root folder. Then
I need something to pull dependencies and setup the environment. `make
environment` took care of that. Things really started rocking as I
iterated on a generic `Makefile`.

Then something strange and interesting started. I started to use
`make` to launch docker containers as part of the `environment`
target. I combined those with `-d` & `--name`, save container ids to a
file with a redirect and voilla. There's a way to start long running
processes with a single command. This is not a revolutionary idea but
it allowed me to do things I'd never done before. I think docker is
also responsible because `-d` makes it simple to manage (start/stop)
processes. I started to see the entire codebase as processes and only
processes. Processes have their owned defined public interfaces
(ports) and can be tested as such. Naturally it would be possible to
start another process that could communicate over the public interface
as a smoke tests. Does the process speak HTTP? Great, fire some `curl`
commands. Does the process speak thrift? Great, start a thrift client
and make some RPCs. Does the code base have some CLI utils to go with
it? Great, then write a make target to call those things.

This unrelated workflow change has completely changed how I view my
software and the verification of process deliverables. This is
something I never expected. I stopped thinking in a whitebox and
shifted to more on black box deliverables. There are only so many
things you can do if you only focus on internals. If you never start
the process and communicate with it your testing is a lie--pure and
simple. These workflows have also drastically increased software
quality more than anything I've done since I started doing TDD.

At this point my workflow goes like this:

1. `make dependencies` - build any dependencies (may pull down
	 external libraries, compile things, or anything like that)
1. `make` - build the project
1. `make environment` - build the project; start processes delivered
	 by the project and any other long running prcessed needed in
	 development
1. `make test` - quick unit tests; should execute as quickly as
	 possible and may not by exhaustive
1. `make test-ci` - run every possible test
1. `make clean` - remove project artifacts and stop anything

Then there are various other test targets. Ruby projects always have
`make test-boot`. This actually start the process in a given
environment. If the process has some CLI utils there is `make
test-cli`. The list goes on and depending on the project.

This workflow dramatically increased my work
quality. I suggest you look into these things as well. They may be as
transformative for you as they are for me.

If you want concrete examples, then wait for the next post. That post
is about replacing rake with make for great good.
