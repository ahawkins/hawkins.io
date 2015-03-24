---
layout: post
title: "On Ruby"
---

I haven't been an active member of the Ruby community for sometime
now. My last real active participation was just about year ago at
Rails Conf where I did workshop on application architecture, then a
few months before that a WrocLove.rb. I haven't been blogging either.
I've been writing a bit of FOSS Ruby at work, but in general things
have been quiet on the front. The reason is simple: Ruby has slowly
turned me into a grumpy old ruby programmer.

In the beginning working with Ruby was stimulating and interesting.
The dynamsicm was dazzling. Even to this day, the metaprogamability
never ceases. Recent I wrote a bit of code to walk the class hieharchy
and use some metaprogramming to dynamically look up constants for
[thrifter][]. Still cool. But that's not all there is. There's the
ecosystem itself and technical values generally promoted by the
community. In general there are few good ones: write "clean" code & do
testing. However the Ruby ecosystem is quite difficult to work with
for long term productivity.

Recently I've been lucky enough to avoid HTTP+JSON for the majority of
work. This has been great because there's been no bullshit for me to
worry about. No frameworks, no bloated libraries. Just straight up
Ruby and essentially just concord and thrift in the Gemfile. Naturally
the code I'd been working needed to track errors. I'd been using
Honeybadger for some time. I'd never paid attention to any of their
Rails integrations or things like that. I also used their public API
directly or use their simple and effective Rack middleware for Rack
applications so I was comfortable making the method calls myself. One
of our internal libraries had a dependency on honeybadger. I need to
upgrade it and through some other things ended up updating from
version 1.x to 2.0. This verison bump brought so much frustration to
the surface & I was pretty pissed off the rest of the day.

Why was it so bad? My test were failing
because the library did not have an API key. I thought to myself, hmm
ok. Surely there must be some way to disable this. Turns out there's
no real easy way to do that.
I happened to have required sidekiq & its web UI. Which in turn
requires sinatra. Honeybadger than monkey patches itself in Sinatra so
that simply defining a sinatra subclass will start it's agent. What.
On top of that, there document on how to simply configure the agent
has gone. Now the libray was intended to be configured through global
state such as environment variables or files in specific locations. I
dug through the code to figure out how I could disable behavior and
how I could get it stop spewing logs everywhere. Eventually I figured
out why this was happening. All the offending code lives in their
[sinatra integration][]. After an hour or two figuring out this
nonsense I decided it wasn't worth it spend any time and just locked
the gem at version 1.x. I also decided that I'd never use honybadger
again and that I'd move my team away from their service because I
consider this destructive programming. Then I realized something I'd
been hearing for a while in some conversations: "because Ruby."

I call out the Honeybadger gem specifically because was the most
recent time I'd been bit by a seemingly good thing promoted in the
community: monkey patching third party code. Now I don't fault HB for
making their code this way. It provides their customers with direct
business value: "just `require 'honeybadger'` and you're done!" I
don't agree with this sort of practice. There are hundreds and
hundreds of libraries doing the same thing. Monkey patching is fine,
just make it opt in at least. Provide something like
`your_library-sinatra`, but sigh this is not the default behavior.
Global load order and monkey patching are standard issue and all the
technical problems that come with.

This sort of thing has made me grumpy over the years. I'm distrustful
of everything but a small set of libraries I've personally vetted or
are authored by people I respect. Why is this important? Without a
certain level of scrutiny you will introduce odd and hard to reproduce
bugs. This is especially important because Ruby offers you no
gaurentee whatever the state your program is when a given method is
dispatched. Constants are not constants. Methods can be redfined at
run time. Someone could have written a time sensitive monkey patch to
randomly undefine methods from anything in `ObjectSpace` because they
can. This is why ruby programmers have gotten good at testing: that's
the whole way we can know anything works. Those examples are
(hopefully) ludacris but it could happen. I'm not against dynamic
languages. I quite enjoy them. However with great power comes great
responsiblity. I've come the realize the wider ruby ecosystem does not
take this responsibility seriously.

My friend Markus Schirp (@\_m\_b\_j)[https://twitter.com/_m_b_j])
tweeted me something that summed up my current opinion on Ruby & the
wider ecocystem.

<!--
<blockquote class="twitter-tweet" data-conversation="none"
lang="en"><p><a href="https://twitter.com/adman65">@adman65</a>
I&#39;m looking forward to use a language where I do not rely on the
discipline (not to do certain antifeatures) of others.</p>&mdash;
Markus Schirp (@_m_b_j_) <a href="https://twitter.com/_m_b_j_/status/566995405372932096">February
15, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>
-->

That's what I'd been doing for a long time. I think many other people
are doing the same thing. It's not just about monkey patching or
dealing with other people's code. It's about the focus and drive of
the community. It seems that Ruby will forever be slanted towards web
applications. I think it's wondeful for many other things but that's
just where it sits in general usage bucket. I don't care about web
applications. I don't care about libraries to create form objects to
work around the fact that `application/x-www-form-urlencoded`
bullshit. I don't have any interest in reading or seeing general
separating persistence from business logic is still up for dicussion.
Nor do I care about new fancy JSON serialization libraries. But this
where the effort goes into and what the general discussion is about.

<!--
<blockquote class="twitter-tweet" lang="en"><p>Develop in a way the likeliness of bugs caught only by discipline is minimized.</p>&mdash; Markus Schirp (@_m_b_j_) <a href="https://twitter.com/_m_b_j_/status/570015282812608512">February 24, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
-->

Markus makes another great point. The amount of discipline that goes
into writing acceptable (in my opinion) production Ruby code is
astoundingly high. You need: 1) very good unit tests. 2) even more
integration tests for the highest level possible, 3) 100% mutation
coverage to cover all the things your unit & integration tests don't,
4) process-to-process testing (e.g. if you have a network server,
start a client and talk to it). Then at that point you could consider
putting this code into production. That still doesn't cover the
library that may alter their behavior depending on some environment
variable! You'll be suprised how many bugs you find if you go through
his entire progression. Then ask yourself if you still feel confident
in what you just committed.

At the end of the day it's all about confidence: is this good enough
to go into production? Fact of the matter for me is I think that Ruby
is not helping me produce high quality software (which is extremely
important to me professionally and personally). It's turning into an
uphill battle with diminishing returns.

That's why I'm off Ruby. I think you should revaluate your position as
well. There's certainly money to be made and perhaps it's interesting
to you--but take a look around. There are other options out there that
offer a more sane engineering environment & ecosystem.

If you do decide to stay and work on Ruby things I recommend you
immediately audit your `Gemfile` and try to remove 75% of the gems or
at least seriously consider why it's there. In my experience I've only
needed a few gems across all projects over the past ~4 years. Here's
pretty much all you need to get 99% of the way:

* `delegate` - `DelegateClass` is the shit.
* `forwardable` - `def_delegators` makes composition easy. No
	dependencies required
* `json` - Standard library is where it's at
* `time` - `Time#iso8601`
* `logger` - `Logger.new($stdout)`. Have never seen a use case where
	something more "powerful" than the standard library logger is not
	enough.
* `set` - Fundamental data type that's nice to work with
* `securerandom` - `SecureRandom#uuid` & `SecureRandom#hex` are
	useful in many situtations
* Minitest - [Bow Before Minitest](https://speakerdeck.com/ahawkins/bow-before-minitest)
* [concord][] - I cannot live without this. Dead simple composition
	without the boiler plate
* [faraday][] - If you need an HTTP client this is it. Minimal
	dependencies and makes `net/http` useful.
* [statsd-ruby][] - Minimal, no dependencies, no problems
* [redis][] - Ofifical and best redis driver
* [mongo][] - Official and fully featured mongo driver
* [sequel][] - Hands down the best SQL library (& minimal active
	record pattern based ORM) the ecosystem has to offer
* [connection\_pool][] - Fantastic connection pool library with no
	dependencies and does exactly what you expect: create thread-safe
	connection pools.
* [webmock][] - Sometimes you need this sort of thing. Don't waste
	your time with anything else. Webmock does everything I've ever
	needed and will probably for you too.
* [rack-test][] - If you need to test rack apps this is the only way
	to do it.
* [mustache][] - Only sane way to do templating. I use ERB when I
	don't care about maintainability.
* [puma][] - Pretty damn good rack server.

Honorable mentions:

* [Virtus][] - For when you need type coercions. I don't use this in
	new code anymore.
* [ROM][] - I respect the hell out of Piotr for all his work on this
	but I can't put it in the must have list. In general a data mapper
	is powerful abstraction that fits niceley between things like a row
	data gateway, active record, or a repository. I encourage you to
	look at this library but don't shy away from writing an application
	specific persistence layer. It's easier than you think.
* [factory\_girl][] - Many codebases need factories, and not just for
	persisted objects! Unfortunately I cannot recommend factory girl
	glboally because it depends on the mother of all transitive
	dependencies: ActiveSupport. However it's by far and away the best
	factory library out there. I do not recommend [fabrication][]
	because it's obession with `instance_eval` (which should never used
	in a public API).
* [sinatra][] - I like sinatra but think there may be something
	better. Beware of libraries monkey patching it though. Building
	large sinatra applications can be a bit weird but doable. Pairs very
	nicely with [mustache-sinatra][].

That's it. Those libraries have gotten me & my team quite far while
staying (somewhat) sane.
