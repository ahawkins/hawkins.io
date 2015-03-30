---
layout: post
title: "On Ruby"
---

I haven't been an active member of the Ruby community for sometime
now. My last real active participation was just about year ago at
RailsConf where I did workshop on application architecture. I haven't
been blogging either. I've been writing a bit of FOSS Ruby at work,
but in general things have been quiet on the front. The reason is
simple: Ruby has slowly turned me into a grumpy old programmer.

In the beginning working with Ruby was stimulating and interesting.
The dynamism was dazzling. Even to this day, the metaprogramming &
introspection methods continue to impress. Recent I wrote a bit of
code to walk the class hierarchy and use metaprogramming to
dynamically look up constants for [thrifter][]. Still cool. But that's
not all there is. There's the ecosystem itself and technical values
generally promoted by the community. In general there are few good
ones: write "clean" code & do testing. However the Ruby ecosystem is
quite difficult to work in long term--it's been about 6 (serious)
years for me.

Recently I've been lucky enough to avoid HTTP+JSON for the majority of
my work. This has been great because there's been no bullshit for me to
worry about. No frameworks, no bloated libraries. Just straight up
Ruby and essentially just concord and thrift in the Gemfile. Naturally
the code I'd been working needed to track errors. I'd been using
Honeybadger for some time. I'd never paid attention to any of their
Rails integrations or things like that. I also used their public API
directly or use their simple and effective Rack middleware for Rack
applications so I was comfortable making the method calls myself. One
of our internal libraries had a dependency on honeybadger. I need to
upgrade it and through some other things ended up updating from
version 1.x to 2.0. This version bump soured the rest of the day.
The experience and real world conversations brought a bunch of lurking
opinions to the surface.

Why was it so bad? My test were failing
because the library did not have an API key. First off I thought why
is this happening? The library is not configured in the test
environment. This was still true. I thought to myself, hmm
OK. Surely there must be some way to disable this. Turns out there's
no real easy way to do that. The rest can only be summed up with a
simple quote:

> Because Ruby.

Now the library is intended to be configured through global state such
as environment variables or files in specific locations.  How is this
better than something like `Honeybadger.api_key =
ENV.fetch('HONEYBADGER_API_KEY)`? Everything that works by this sort
of global state has some local state. I was not going to restructure
deployment, testing, and environment variables because of this
nonsense. I dug through the code to see if I could find the local
state or disable this weird auto start behavior. Their logger was also
spewing log messages to `$stdout`. The "solution" is to an environment
variable to `LOG_FILE=/dev/null`. Or you know, maybe you could let me
assign a logger object?

I dug through the code to see what object actually encapsulated the settings
and where this logger object was. Naturally there wasn't much
documentation on the internals. Everything pointed to environment
variables. I did figure out how to set the API key myself but I could
not figure out why the library was sill spewing things to `$stdout`.
The offending code lives in their [sinatra integration][].

I happened to have required sidekiq & its web UI. Which in turn
requires sinatra. When honeybadger is required, it detects which
constants are defined and will then require other files. Due to my
load order, Honeybadger then monkey patches itself into Sinatra so
that simply using a sinatra subclass will start it's agent. What.
Turns out the only way to do anything about this was to set global
environment variable. After an hour or two figuring out this nonsense
I decided it wasn't worth any time and just locked the gem at version
1.x. I also decided that professionally or personally discontinue my
business with Honeybadger because this is just bad design making it's
way into other code bases. It's not just done by third parties. It's
not just the libraries. The standard library also breaks [fixnum
operations][mathn bug] through monkey patching. There's also problems
with [timeout][timeout bug].

I call out the Honeybadger gem specifically because was the most
recent time I'd been bit by a seemingly good thing promoted in the
community: monkey patching third party code. Now I don't fault
Honeybadger for making their product this way. It provides their
customers with direct business value: "just `require 'honeybadger'`
and you're done!" I don't agree with this sort of practice. There are
hundreds and hundreds of libraries doing the same thing. Monkey
patching is fine, just make it opt in at least. Provide something like
`your_library-sinatra` or `honeybadger/sinatra`, but sigh this is not
the default behavior.  Global load order and monkey patching are
standard issue and all the technical problems that come with. The
constant onslaught of undisciplined ruby code has really worn me down
over the years. Now-a-days I feel like Clint Eastwood in Gran Torino
just waiting to yell "get of my lawn" and shake a beer.

I'm distrust everything but a small set of libraries I've personally
vetted or are authored by people I respect. Why is this important?
Without a certain level of scrutiny you will introduce odd and hard to
reproduce bugs. This is especially important because Ruby offers you
absolutely zero guarantee whatever the state your program is when a
given method is dispatched. Constants are not constants.  Methods can
be redefined at run time. Someone could have written a time sensitive
monkey patch to randomly undefined methods from anything in
`ObjectSpace` because they can. This example is so horribly bad that
no one should every do, but the programming language allows this. Much
worse, this code be arbitrarily inject by some transitive dependency
(do you even know what yours are?).  T his is why ruby programmers
have gotten good at testing. Ruby programs must be tested extensively.
It's the only way to ship anything with reasonable confidence. I'm not
against dynamic languages. I quite enjoy them. However with great
power comes great responsibility. I've come the realize the wider ruby
ecosystem does not take this responsibility seriously. I say wider
because it's a majority problem and there are people out there writing
pretty damn good and sane code. More on those people later.

My friend [Markus Schirp][] tweeted me something that summed up my
current opinion on Ruby & the wider ecosystem.

<blockquote class="twitter-tweet" data-conversation="none"
lang="en"><p><a href="https://twitter.com/adman65">@adman65</a>
I&#39;m looking forward to use a language where I do not rely on the
discipline (not to do certain antifeatures) of others.</p>&mdash;
Markus Schirp (@_m_b_j_) <a href="https://twitter.com/_m_b_j_/status/566995405372932096">February
15, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

That's what I'd been doing for a long time. I think many other people
are doing the same thing. It's not just about monkey patching or
dealing with other people's code. It's about the focus and drive of
the community. It seems that Ruby will forever be slanted towards web
applications. I think it's wonderful for many other things but that's
just where it sits in general usage bucket. I don't care about web
applications. I don't care about libraries to create form objects to
work around the fact that `application/x-www-form-urlencoded`
bullshit. I don't have any interest in reading or seeing general
discussions on separating persistence from business logic is a good
thing. Nor do I care about new fancy JSON serialization libraries. But this
where the effort goes into and what the general discussion is about.
This is primarily because these efforts on making code easier to write
instead of focusing on making it more **correct**. [Mutant][] is the
only project (I know of) happening the Ruby community to make programs
more correct.

<blockquote class="twitter-tweet" lang="en"><p>Develop in a way the likeliness of bugs caught only by discipline is minimized.</p>&mdash; Markus Schirp (@_m_b_j_) <a href="https://twitter.com/_m_b_j_/status/570015282812608512">February 24, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Markus makes another great point. The amount of discipline that goes
into writing acceptable (in my opinion) production Ruby code is
astoundingly high. You need: 1) very good unit tests. 2) even more
integration tests for the highest level possible, 3) 100% mutation
coverage to cover all the things your unit & integration tests don't,
4) process-to-process testing (e.g. if you have a network server,
start a client and talk to it). Then at that point you could consider
putting this code into production. That still doesn't cover the fact
library that may alter behavior depending on some environment
variable! You'll be surprised how many bugs you find if you go through
his entire progression. Then ask yourself if you still feel confident
in what you just committed.

At the end of the day it's all about confidence: is this good enough
to go into production? For me, Ruby is not making it easier for me to
produce high quality software. This is extremely important to me
personally and professionally. I see every uncaught error or incorrect
business logic implementation as fundamental failure on my part. I
don't expect to write bug free code, but I do expect to eliminate of
100% of certain classes of errors. Ruby is not helping me in that
battle, instead my continued Ruby use is an uphill battle with
diminishing returns.

If you take anything away from this grumpy post you should reevaluate
your position on the tools you use and ask yourself: is this helping
me produce higher quality work? Maybe you end up at the same place I
am. There's certainly money to be made with ruby and perhaps it's
interesting to you but take a look around. There are other options out
there that offer a more fundamentally sane engineering environment &
ecosystem. Personally I'm considering D & Erlang.

If you do decide to stay and work on Ruby things I recommend you
immediately audit your `Gemfile` and try to remove 75% of all your
dependencies. In my experience I've only needed a few gems across all
projects over the past ~4 years. Here's pretty much all you need to
get 99% of the way.

All of these library are specifically chosen because:

* They have minimal to zero dependencies
* Their transitive dependencies are acceptable
* They do what they say on the box
* Easy to work with & build more complex functionality on top of
* Well maintained

So here we go!

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
* [minitest][] - [Bow Before Minitest](https://speakerdeck.com/ahawkins/bow-before-minitest)
* [concord][] - I cannot live without this. Dead simple composition
	without the boiler plate
* [lift][] - Hash initializer + block form. Remarkably simple and
	effective way to remove duplicating this hundreds of times.
* [faraday][] - If you need an HTTP client this is it. Minimal
	dependencies and makes `net/http` useful.
* [statsd-ruby][] - Minimal, no dependencies, no problems
* [redis][] - Official and best redis driver
* [mongo][] - Official and fully featured mongo driver
* [sequel][] - Hands down the best SQL library (& minimal active
	record pattern based ORM) the ecosystem has to offer
* [connection_pool][] - Fantastic connection pool library with no
	dependencies and does exactly what you expect: create thread-safe
	connection pools.
* [sidekiq][] - The best job queueing system Ruby has to offer.
* [webmock][] - Sometimes you need this sort of thing. Don't waste
	your time with anything else. Webmock does everything I've ever
	needed and will probably for you too.
* [rack-test][] - If you need to test rack apps this is the only way
	to do it.
* [mustache][] - Only sane way to do any kind of templating. I use ERB when I
	don't care about maintainability.
* [puma][] - Pretty damn good threaded rack server.

Honorable mentions:

* [Virtus][] - For when you need type coercions. I don't use this in
	new code anymore. This only useful when you're dealing with random
	untyped garbage input.
* [ROM][] - I respect the hell out of
	[@solnic](https://twitter.com/_solnic_) (he falls in the well
	respected author list) for all his work on this
	but I can't put it in the must have list. In general a data mapper
	is powerful abstraction that fits niceley between things like a row
	data gateway, active record, or a repository. I encourage you to
	look at this library but don't shy away from writing an application
	specific persistence layer. It's easier than you think using the low
	level libraries like Sequel or a raw DB driver.
* [factory_girl][] - Many projects need factories, and not just for
	persisted objects! Unfortunately I cannot recommend factory girl
	globally because it depends on the mother of all transitive
	dependencies: ActiveSupport. However it's by far and away the best
	factory library out there. I do not recommend [fabrication][]
	because it uses `instance_eval` in the public API. FactoryGirl uses
	instance eval for definitions but not in the public API.
* [sinatra][] - I like sinatra but think there may be something better
	at this point. I mainly stick with Sinatra because you can learn
	everyting in a short time and in generally solves most of the
	problem: map complicated path to code block. Beware of libraries
	monkey patching it though. Building large sinatra applications can
	be a bit weird but doable. Pairs very nicely with
	[mustache-sinatra][].

That's it. Those libraries have gotten me & my team quite far while
staying (somewhat) sane. I hope that using any of these libraries
reduces our code and makes you more confident in understanding your
solution.

[Markus Schirp]: https://twitter.com/_m_b_j_
[sinatra integration]: https://github.com/honeybadger-io/honeybadger-ruby/blob/master/lib/honeybadger/init/sinatra.rb#L8
[mutant]: https://github.com/mbj/mutant
[concord]: https://github.com/mbj/concord
[lift]: https://github.com/ahawkins/lift
[faraday]: https://github.com/lostisland/faraday
[stats-ruby]: https://github.com/reinh/statsd
[redis]: https://github.com/redis/redis-rb
[mongo]: https://github.com/mongodb/mongo-ruby-driver
[sequel]: https://github.com/jeremyevans/sequel
[statsd-ruby]: https://github.com/reinh/statsd
[connection_pool]: https://github.com/mperham/connection_pool
[sidekiq]: http://sidekiq.org
[mustache]: https://github.com/mustache/mustache
[webmock]: https://github.com/bblimke/webmock
[rack-test]: https://github.com/brynary/rack-test
[mathn bug]: https://bugs.ruby-lang.org/issues/2121#change-32976
[timeout bug]: http://headius.blogspot.de/2008/02/rubys-threadraise-threadkill-timeoutrb.html
[factory_girl]: https://github.com/thoughtbot/factory_girl
[sinatra]: http://www.sinatrarb.com
[ROM]: http://rom-rb.org
[puma]: http://puma.io
[minitest]: https://github.com/seattlerb/minitest
[virtus]: https://github.com/solnic/virtus
[fabrication]: http://www.fabricationgem.org
[thrifter]: https://github.com/saltside/thrifter
