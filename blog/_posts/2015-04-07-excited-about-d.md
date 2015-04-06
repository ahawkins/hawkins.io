---
layout: post
image: http://dlang.org/images/dlogo.svg
---

I've been actively looking to replace Ruby as my general purpose
language with something else. High level reasons are:

* The community's primary interest in web applications
* Going against the majority of the ecosystem is an uphill battle
	(shout out to those of you writing sane code, you know who are are!)
* Ruby was never intended to be correct, it was designed to make
	programmers happy. There are many tradeoffs I don't agree with.
* Ruby is dynamic
* Performance. I know there are other interpreters but in general Ruby
	is on the slower side of interperted languages.
* Writing Ruby code is not challenging or interesting at this point

I evaluated the usual contenders like Haskell,Clojure & Go but nothing
got me excited enough to write any code.
At work we were green fielding a bunch of new services. A coworker
mentioned he'd done a prototype in [D][]. I never heard about it
before and asked about it. He briefly described it. I made a mental
note to look into it, but since the prototype never went any further
the interest was generally shelved. Fast forward a bit. I had an idea
for a CLI program I wanted to distribute. I did not want to ship code
on an interpreted stack then I remembered that my coworker mentioned
D. It was a good as time as any to investigate.

I purchased [The D Programming Language][official book] and cruised
though the shorter online [Programming in D][online book] book. They
peaked my interest. The more I read, the more it seems that D has
everything I want in a programming language. Turns out I learned
enough to write a simple test tool for one of the company API. It
was a pleasant experience after I got over the "language X
noob" problems. So in this post, I want to share with you why I'm
excited about D and am looking forward to using personally &
professionally.

## Introducing D

First off a bit about the language itself. [D][] is a statically typed
multi paradigm language that compiles to native code. I say multi
paradigm because it has first class functions, closures, as well as
classical inheritance. The syntax is C like, so in general the code
will appear as you expect. D also has a decent standard library so you
can `map` and `filter` like a sensible language. Unlike C, D is
garbage collected (however you can opt-in to raw memory management if
needed). So with that in mind let's get to the good stuff!

### Types

The type system is not revolutionary (ala Idris), but it cuts down on
the boilerplate required in a less advanced type system (ala
Go/Java/C/C++). The tl;dr here is that it does have types and writing
the type is not required every time. The `auto` type can be used for
assigning variables and for function return values. This makes it
possible to _almost_ never write a type. The compiler will infer as
much type information as possible. I think 90% of types in my program
are `auto`. Here's an example:

	auto name = "Adam Hawkins";
	// same as
	string name = "Adam Hawkins";

	// auto can also be used for functions
	auto getName() {
		return "Adam Hawkins";
	}

Seemed to work out well enough for me in my small program. However I
did think where _are_ the types? Java was the last strongly typed
language I worked in so I had grown to assume that type systems meant
type names everywhere. This is not the case.

### Contract Programming & Class Invariants

D allows you to create input and output contracts for functions. The
contracts are automatically checked at runtime. This is important
because I want my programs to be fundamentally more correct and I want
them to explode if they fail to be. Here's a made up example for a
function that should execute tests. A test suite should require more
than one test and return at least one result. If that doesn't happen
then there is a serious problem. Here's some code:

	enum TestResult { PASS, FAIL };
	TestResult[] runTests(Test[] tests)
	in
	{
		assert(!results.empty)
	}
	out(result)
	{
		assert(!results.empty)
	}
	body
	{
		TestResult[] results;

		// Break contract!
		return results;
	}

Note that this program would compile but explode at runtime. This same
concept can be applied to classes via invariants. D will enforce the
invariant holds true before and after each method call. Note that
contracts can also be added to classes methods. These two constructs
can go a long way to ensuring a program's correctness over its
lifetime.

### Built in Tests

The compiler has built in support for running tests. Every file can
declare a `unittest` block. The block is compiled into the program and
will run when the program runs. If the tests fail, the program will
explode. This nice because it makes TDD easy and all the required bits
are available without having to import any dependencies. Here's an
example:

	// my_name.d

	unittest {
		assert("Adam Hawkins" = myName());
	}

	auto myName() {
		return "Adam Hawkins";
	}

	// Now at the console
	// note rdmd is short for "run dmd" which is "compile & run" in
	// in a single command.
	$ rdmd --main -unittest

### UFCS

UFCS is short of "Universal Function Call Syntax". It works like this:

	// Define a function taking a string as the first argument
	auto isMyName(string s) {
		return s == "Adam Hawkins";
	}

	auto name = "Adam";

	// As you'd expect
	isMyName("Adam");

	// Now call the same method one or two ways
	name.isMyName()

This is all done by the compiler so there's no meta programming or
monkey patching involved. I like this because it gives the illusion of
certain types are extended. It also allows you to write the code in
whichever syntax make sense to you.

### foreach/map/filter/parallel

D has a built in looping construct for ranges called `foreach`.

	import std.stdio;

	auto names = [ "Adam Hawkins", "Peter Esselius" ];

	foreach(name; names) {
		writeln(name);
	}

Naturally you can `map` as well.

	import std.stdio, std.algorithm;

	auto names = [ "Adam Hawkins", "Peter Esselius" ];
	// Become Svensk with a lambda!
	auto swedishNames = names.map!(n => n ~ "son");

	foreach(name; names) {
		writeln(name);
	}

Parallelization is easy as well.

	import std.stdio, std.parallelism;

	auto names = [ "Adam Hawkins", "Peter Esselius" ];

	foreach(name; taskPool.parallel(names)) {
		writeln(name);
	}

### Grab Bag

Here a few things that are cool but can't easily put together a small
snippet to explain them.

* Metaprogramming support! For example the Thrift D library parses the
	Thrift IDL and generates D code at compile time.
* `scope`. You can write things like `scope(failure) { ... }` to
	clean up after exceptions. You can create as many of these as you
	like without having to coordinate nested try/catch blocks.
* Different optimization levels. Things can be tagged `@safe` or
	`@system` for differnt performance and access levels.
* `@property`. This allow something like `bool empty()` to be called
	as `empty` a.k.a. it can be accessed like a property instead of a
	method.

## Wrap Up

All in all I'm quite excited about the programming language itself.
The only drawback is the current community. It's very small right now.
The community is actively working on ways to improve itself and get
the word out. Everyone was extremely helpful on the IRC channel when
I was struggling through my first program. Even if you do not chose to
use D, take a look. It certainly expanded my mind and showed me there
are other great languages out there. I also highly recommend [The
D Programming Language][Official book] book. It's an easy read for
experienced programmers and the author's style makes it more
enjoyable.

[D]: http://dlang.org
[Official book]: http://www.amazon.com/The-Programming-Language-Andrei-Alexandrescu/dp/0321635361
[Online book]: http://ddili.org/ders/d.en/index.html
