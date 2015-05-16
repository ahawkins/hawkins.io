---
title: "Replacing Rake with Make"
layout: post
---

I recently wrote about [why I use make][]. This post is about I
elminated rake from my workflow by using the much superior make.
Here's how you do it.

Most ruby projects have few things in common: they have a `Gemfile`
and have tests. Most ruby code cannot be run without dependencies
installed (e.g. `Gemfile.lock` exists and `bundle install` has run).
The dependencies are required to run tests. Tests are run in many
different ways, but by rule of thumb there is a directory containing
all the tests. It's simple to create a `Makefile` that models this
workflow. I'll go through it slowly since I think many ruby developers
are familiar with writing a `Makefile.

First create a target that builds `Gemfile.lock`.

	Gemfile.lock: Gemfile
		bundle install
		touch $@

The part before the `:` declares the output file. The part after `:`
delcares pre-reqs/dependencie. The lines after (tab indented) define
the commands to create specified file. The above target defines
`Gemfile.lock` and is dependent on `Gemfile`. So whenever `Gemfile`
changes, then `Gemfile.lock` should be rebuilt. Future targets can
depend on `Gemfile.lock` and thusly its transitive dependencies. `$@`
is an automatic variable. It is the defined output file
(`Gemfile.lock`) in this case. It's useful since you do not have to
repeat and reducing duplication related errors. The `touch` command is
added since I've experienced `make` get confused about file
modification on different filesystems. `touch` ensures the
modification time is updated since `make` uses modification times to
update the dependency graph.

Now it's time to define a target to run tests. This accomplished by
using make's standard library functions. Yes, `make` is so powerful that
it has its own standard library! As mentioned ealier, most ruby
projects keep tests in a folder and follow a convention. We can use
the `wildcard` function to glob them all and pass them off to some
command.

First off define a variable to hold all the files

	TEST_FILES:= $(wildcard test/*_test.rb)

There are two things going on here. The `:=` syntax declares a
variable named `TEST\_FILES` with the value of the `wildcard`
function. The `:=` means evaluate now. There is also `=` syntax which
means evaluate at every use. This is a subtle difference. In general
you should use `:=`. Variables and function calls are written like
`$(...)`. Note that the `()` are just separators. `{}` could be used
as well, however it's common pracice to use `()`. Now define a target
to use those files.

	.PHONY: test
	test: Gemfile.lock
		@ruby -I$(PWD) $(foreach file,$(TEST_FILES),-r$(file)) -e exit

There's a bunch going on in this snippet. First the `.PHONY`
annotation declares that this target does not produce any files. It
also means it should be invoked whenever its called. The next line
uses the built in `foreach` to "map" each item in `TEST\_FILES` into
`-r$(file)`. Make contains a functional language for operating on
lists delinated by whitespace. `-I$(PWD)` uses the `make` provided
value for the current working directory to set the load path. This is
required since `wildcard` produces relative paths. If you don't want
to modify the load path then, the command could be rewritten to use
absolute requires like so: `-r$(PWD)/$(file)`. The `ruby` command
requires either a program to execute or `-e`. `exit` is passed to `-e`
triggering the ruby interperter to exit. This works perfectly with
minitest and eliminates the requirement for having a test runner
program. The prepended `@` supresses printing the command to stdout.
This ensures we only see the nice dots from the test suite.
`Gemfile.lock` is listed as a preqreq. This creates a nice workflow.
Edit the `Gemfile` and run `make test`. New dependencies are
automatically installed before each test run.

Great, now `make test` will run the tests. It's also possible to make
this the default behavior if desired. Set the `.DEFAULT\_GOAL`
variable to a specific target.

	.DEFAULT_GOAL:=test

Now run `make`. Voilla! The most common action with the least typing.
The final `Makefile` looks like this:

	TEST_FILES:= $(wildcard test/*_test.rb)

	.DEFAULT_GOAL:=test

	Gemfile.lock: Gemfile barcelona.gemspec
		bundle install
		touch $@

	.PHONY: test
	test: Gemfile.lock
		@ruby -I$(PWD) $(foreach file,$(TEST_FILES),-r$(file)) -e exit

That my friends should be enough to get you off the ground using make
for the most common ruby related activities. You may be thinking, well
I use `rake` for more things than just running tests. What should I
do?

The answer is simple: stop using rake. Odds are you're using rake as a
way to run ruby code. Instead create a CLI to do the the thing. This
should make you consider how to design, thus how to test it, and
thusly create better software. You'll thank me in time.

I'll leave with a larger `Makefile` for a docker & ruby based
project:

<script src="https://gist.github.com/ahawkins/36f10323de978f173a1c.js"></script>
