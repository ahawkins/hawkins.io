---
layout: post
title: Introducing Field Notes & Code Safari
image: http://ecx.images-amazon.com/images/I/61ChcbV2nbL._SY355_.jpg
---

I've been having a lot of internal & external discussion on software
in recent times. I've wanted to do more writing about it, but never
felt like there was enough for a blog post, but was always left with
small bits of text. It's been repeated that the best thing you can do
is keep a development journal. So I give to you my [field
notes][]! My field notes are just that, observations and thoughts on
the day to day work of shipping code. You can find the [source][] on
GitHub. I'll be publishing the notes every once in a while so check
back. The repo also includes a helpful `fn` utility you can put on
your `$PATH` for writing notes during your daily work. I'm looking
forward to trying this and I suggest you do the same.

It's also a prefect way to kill two birds with one stone. I have been
grumpy and complaining about Ruby for a long time now. Complaining is
not a productive activity! I mentioned somethings I do to keep my ruby
development sane in the [previous post][]. Writing this little ruby
application was a nice way to put that advice (among others) into
practice. I've taken the time to prepare a short code safari
documenting the code and the design decisions that went into it. This
is a close as it gets as my current thoughts on writing ruby. It's not
a complete summary but it does cover my current patterns.

## Code Safari

The repository is different than many other ruby projects you'll come
across. This post explains why this is and also illustrates how I
structure and develop most of my software. First, let's start off
with the directory structure:

* `bin/` - Contains executables for running the program in production
	environments.
* `script/` - Contains executables for non-production environments
	(e.g. installing dependencies, running dev servers, helping with
	tests etc).
* `src/` - The domain specific source code (as opposed to `lib/` [not
	present in this project] which contains source portable across
	different progems).
* `test/` - The test suite
* `util/` - Odd ball out, contains a script intended for distribution.
* `Makefile` - Rules to build and test this project
* `boot.rb` - Entry point for executables, used to boot the ruby
	process. This requires all files and does any other appropriate
	configuration.

Note that there are other files but there uses are project specific or
is obvious (e.g. `Gemfile`). I don't tend to enforce a strict
hierarchy inside each folder, but always stick with this root folder
structure. The other key differences include:

* Using `bin/server` to ship an executable on top of `rackup`. I don't
	use gem executables directly these days since they assume a specific
	way to load code.
* `rake` is not used. `make` is better and more powerful. This is a
	whole another story, but in general using `make` provides a
	consistent experience across projects regardless of implementation.
	Using `make` also eliminates a useless dependency.
* Bash & [bats][] used for other things
* `script/dev-server` for starting a development server. I include
	this script when human interaction is required before shipping. This
	is required because this application deals with graphical elements.
	It is not necessary if this program is purely machine-to-machine
	(since a good test suite ensures high enough confidence). The script
	also setups the development environment in whatever way makes sense.
* Follow the "don't bind directly to 3rd party APIs" principle as much
	as possible. More on this later.
* Mustache used for templates. Logic in templates is not correct.
* No rubucop. Rubocop is a waste of time and provides little
	benefit.

With all that in mind, let's start from the beginning.

## Developing & Testing with Make

I use make to build all my projects. I keep to a standard set of
targets so my work flow is portable. `make test` runs quick tests.
`make test-ci` runs the entire test suite. This project does not have
a `test-ci` target because the test suite is trivial. This is more
useful there are multiple time consuming layers of testing.

The repository contains two artifacts: the ruby web server & the util
script for writing notes. The `Makefile` defines two targets:
`test-src` for testing all the ruby things, and `test-util` for
testing the CLI script. `make test` invokes both (this would usually
the job of `make test-ci`).

Using make is great because it automates trivial things (and is great
for providing each language something to reinvent). It's easy to
define a target to test all the ruby files. Simply tell ruby to
require all the test files and exit. Minitest files are automatically
ran on exit. Problem solved. The `test-src` target also installs gems
if required (through simple file dependency rules). This is useful
because a new developer can clone and run `make test` and all the
correct things happen.

The annotated `Makefile` is presented below for those unfamiliar with
make.

	# Define a variable for all files matching test/*_test.rb
	TESTS:=$(wildcard test/*_test.rb)

	# target to create a temporary directory for dumping fixtures in
	# to test the util CLI. The $@ is an automatic variable and refers
	# name of the target (tmp/scratch).
	tmp/scratch:
		mkdir -p $@

	# Everytime Gemfile changes run bundle install to update the
	# Gemfile.lock
	Gemfile.lock: Gemfile
		bundle install

	# Target to run all ruby tests. It depends on Gemfile.lock (and its
	# transitive dependencies). So you can edit the Gemfile, then run
	# make test and bundle install will happen before the tests. Neat!
	# the @ before the command surpressed printing the command. Instead
	# only the dots from the test suite make it to the screen.
	.PHONY: test-src
	test-src: Gemfile.lock
		@ruby -I$(CURDIR) $(foreach test,$(TESTS),-r $(test)) -e "exit"

	# Target to test the util CLI. It depends on tmp/scratch so it will
	# be created if doesn't exist. The $< is another automatic variable
	# and refers to the name of the first prereq. The target sets
	# expected environments to test values and invokes the bats test
	# file.
	.PHONY: test-util
	test-util: tmp/scratch
		env UTIL=$(CURDIR)/util/fn FIELD_NOTES_PATH=$< bats test/util_test.sh

	.PHONY: test
	test: test-src test-util

	# Every makefile should have a clean target. This should remove all
	# artifacts created by the makefile. In this case we only have one.
	# The target is listed as .PHONY. This means it should always be
	# invoked when called (even is all prereqs are up to date).
	.PHONY: clean
	clean:
		rm -rf tmp/scratch

## Code Internals

The code sticks a few guidelines. Some strictness is unnecessary since
this is a personal project and I'm the primary developer.

There is lots of `tap`. I use `tap` when calling a method and need to
modify the return value before continuing. This is easier to read than
a bunch of lines of `foo.bar =`. The indented block style visually and
conceptually groups this into a single operation for me. Here's an
example from the note parser.

```ruby
Entry.new.tap do |entry|
	meta = YAML.load_file file
	parts = File.basename(file, '.md').match(/\A(\d{4})-(\d{2})-(\d{2})-.+\z/)

	fail RuntimeError, "#{File.basename(file)} does not follow format" if parts.nil?

	entry.date = Date.new *parts.captures.map(&:to_i)
	entry.tag = meta.is_a?(Hash) ? meta.fetch('tag') : 'other'
	entry.content = File.read(file).gsub(/\A---.+---/m, '').strip
end
```

This code could have been better if `Struct#new` accepted a block.
Unfortunately it only accepts `*args`. Right now I don't enforce a
limit for how many lines go into a `tap` block, but the one above is
the longest one I can remember to date.

My current ruby code also uses `Forwardable` & `def_delegators` quite
a bit. The standard library gives you pretty much everything you need.
Also the `Struct.new` in the block form is prevalent in this code
base--especially in the view classes. `Struct.new` with a block is
essentially a `class_eval` which is written in C in MRI.

```ruby
Entry = Struct.new :date, :content, :tag do
	extend Forwardable

	def_delegators :date, :year, :month
end
```

Next up is the separation between my code & library code. This is
paramount in large code bases. This is important because you should
always define the interface that makes sense for the program and
delegate the implementation to libraries. If you don't take anything
else away from this blog post, take this! Libraries are for the
general case and their API may not be exactly what you want. If you
define an interface and stick to it, it's much more difficult for
third party API changes to break your code.

It's not strictly required in a codebase this small, but I do it to
enforce the practice. If you slip in small projects you will slip in
larger projects. Good practice makes good developers. This is obvious
in two key places: the markdown generator and server tests. I think it
shines in the latter case.

I've been doing this for a long time in application code (e.g. code to
talk to HTTP APIs or persistence layer drivers), but I didn't start
doing it in my test suite until recently. The end result is dramatic.
The tests that are easier to maintain and the intent is more clear.
This application contains a web server for displaying notes as HTML.
Capybara is the best tool for testing rack applications.  The DSL
methods are acceptable for the general case but the intent is lost
when used excessively. What does `assert page.has_css?('#foo')`
really tell you. Yes there is no `#foo` element, but what _is_ foo?
This is implicit knowledge shared between the author and the reader.
Instead it's more effective to encapsulate the GUI as a class (Don't
fear the class!) and use command/query methods representing the
concepts in the test. The commands change state and the query methods
are for assertions.

The test suite contains a test for the behavior when there are not
notes to display. Technically this is done by invoking a method to
count elements. I call this method `blank?`. It uses the technical
implementation and returns `count == 0`. The test comes out
wonderfully readable.

```ruby
server.set :notes, [ ]
gui.open_home_page

assert gui.blank?, 'Unexpected notes'
```

Reads like a charm. This implementation is especially powerful because
every GUI is a state machine. In a web application the state is at
least the current path. So the implementation of `blank?` can change
with the current state while keeping a consistent interface for tests.
This has been immensely helpful on larger projects. If you look at the
`GUI` class in `test/server_test.rb` you'll see a crude implementation
of a state machine (assigning to `@current_page`). This codebase does
benefit so much because there are only two screens: the home page and
the monthly view. However as I mentioned before, I stick to the same
principles at this small scale because to be effective in larger
codebases you must be able to execute confidently and automatically in
smaller ones. My only complaint here is that capybara only supports a
single test server. I have a nice GUI instance then I must assign
exterior (global) state in initialize. Sometimes you just can't have
it all. Wouldn't it be nice if the entry point was `driver =
Capybara::Driver.new app`? I suggest you read the whole thing and see
if there are any takeways.

Next I want to call out the test cases themselves. I've working
towards a more useful assertion style. I've come up with
a few rules. These ideas are probably portable across other testing
libraries.

> If there is more than one `assert` or `refute` in a test method,
> then they all must include a useful message.

People say that each test should exactly one assertion. I've never
seen that possible in practice. I keep tests as small as possible but
sometimes you need more than assertion (preconditions anyone?). The message
is important because the provided assertions provided no useful
debugging information. You end up seeing "assertion failed", well yes
I can see that, but why? This serves two purposes. First, it reduces
the time form red to green. If the error message is accurate then
it's easier to correlate the error and previous change. Second, it
clarifies the intent for the reader. The reader sees `assert` is
there, but _why_ is it there? Remember that programming is a two way
conversation between the author and the reader and neither ever share
the same context.

> Prefer custom assertions over built-ins.

This is more about readablity/debugging and based observations on the
80/20 rule in larger codebases. Writing customs assertions is easy and
one of the reasons I [bow before minitest][]. Custom assertions are
just ruby method. They are preferred because they can be named better
than `assert_includes` and can bundle a meaningful error message (
thus save you from writing the same nice error message all over the
suite). Custom assertions also let you compose your classes into
assertions. The fields note application deals with notes so naturally
there is a class for them. The tests uses a GUI class to represent
what's currently shown. So it's natural to create an assertion for
"this note is displayed on the screen". That's exactly what the
`assert_note` method does.

```ruby
def assert_note(screen, note, message)
	assert screen.says?(note.content), message
end
```

This method could easily be written to something like (and I have done
similar things in the past).

```ruby
def assert_note(screen, note, message = nil)
	assert screen.says?(note.content), message || "#{note.content} not shown"
end
```

But by the first point, the generic message does not provide _why_ it
should be on the screen. Here's an example:

```ruby
assert_note gui, note, "Selected months notes should be shown"
```

Now onto the last one worth mentioning.

> Use assert/refute wrappers only when the generated failure message
> aids in debugging.

This one is hard to explain in text so let's see some code. This is
based on observations of the 80/20 rule. In 80% of cases I found the
generated error messages to provide less value than the custom one I
provided. Minitest will print *both*. This is unfortunate. For example
if you have `assert_includes foos, foo, 'blah'` a summary of `foos`,
`foo`, and `blah` are printed to the screen. This inverts the signal
to noise ratio. So I stopped using this form. Instead I use `assert`
and `refute` exclusively paired with the first point. The previous
example becomes `assert foos.include?(foo), 'List incorrect'`. This
keeps failure output small and on point. Most importantly it reduces
the time from red to green. However in 20% of the cases the generated
error messages _were_ useful. This is why I wrote "prefer". These days
I use something other than `assert` or `refute` when the generated
error message will speed up red to green.

Together these three guidelines have made it easier for me to work on
test suite and fix bugs. I want to call out one more I've observed
myself doing consistently.  I use errors a lot. I like my programs to
explode when assumptions are violated. Since I do this, its important
to ensure the error messages contain enough information to remove
them. This results in me pairing `assert_raises` with an
`assert_match` to test it makes _some_ sense.  I say "some" because
the exact text is not important, only that it has a _hint_ of how to
debug it.

Here's an example:


```ruby
def test_fails_if_referenced_link_incorrect
	error = assert_raises RuntimeError do
		generator.html outdent(<<-EOF)
		Something [Link Text][unreferenced-link]
		EOF
	end

	assert_match /unreferenced-link/, error.message, 'Error message not descriptive'
end
```

Note, that I explicitly use `assert_match` instead of `assert foo =~
/bar` because the I need to see `error.message` to understand _why_ the
message is not descriptive.

## Bats Testing & Wrap Up

This piece has turned out to be a bit longer than I expected so I'll
wrap it up. There is a bats test for the util. All deliverables must
be tested. Bash scripts are no different. There's not much else to say
about it besides it exists. Most of my work these days has some amount
of bash in it (primarily to kick off process inside docker containers)
and to help in development and testing. If you are not familiar with
bash than I suggest you learn. The include script shows very basic
control flow and failure handling (and there's tests so it can be
refactored!).

I want to end this piece with a quick discussion on omissions. These
are things that I do on production software that are not present in
this code base.

1. More complete acceptance tests. I use docker for everything these
	 days. The test would go something like this. Start the web server
	 via `bin/server`. Fire off some requests with `curl` and assert
	 they are 200 responses using bats. Crawl the site to ensure all
	 generated links work.
2. `make test-boot`. Luckily this project does not have
	 per-environment configuration. Most of my projects have quite
	 large ruby configuration files. It's likely that there is a syntax
	 error or other logic error in those files. This sort of thing can
	 be (and should be caught) before code goes to those environments.
	 This is done in most cases by `ruby boot.rb` with the appropriate
	 environment variables. This eliminates most common errors.
3. Configuration artifact verification. Most projects have `.json` or
	 `.yml` files scattered through them for various reasons. These
	 tests do not assert on any values, but assert that they can be
	 _parsed_. It's no fun to push a build through CI that fails
	 because the deployment process cannot parse the config file.

I hope that this article has given you a window into how I think about
writing ruby code and maybe some ideas for how you can improve your
own.

_NOTE_: The code examples are taken from a certain commit and may no
longer make sense as this post ages. You can browse the source tree at
the referenced commit on [GitHub][source tree].

[field notes]: http://notes.hawkins.io
[previous post]: /2015/04/introducing-field-notes/
[source]: https://github.com/ahawkins/field_notes
[source tree]: https://github.com/ahawkins/field_notes/tree/4630b85bca57508b25443d1aaf47955afecf57bb
[bats]: https://github.com/sstephenson/bats
[bow before minitest]: https://speakerdeck.com/ahawkins/bow-before-minitest
