---
layout: post
title: "Lagom is not Just for Swedes"
---

<blockquote class="twitter-tweet" lang="en"><p>summary of DHH&#39;s
point: tests, yes, test-first, no - unit tests, yes, but shifting
weight into systems tests - bonus: run from astronauts</p>&mdash;
Xavier Noria (@fxn) <a
href="https://twitter.com/fxn/statuses/458952270265077760">April 23,
2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

DHH's Railsconf 2014 key note was well delivered and naturally started
discussions, shock, horror, and disappointment on the twittersphere. I think
his primary message was miscommunicated.

<blockquote class="twitter-tweet" lang="en"><p>Everyone is wrong.
Everyone is right. Nuanced views exist. Disagreement is healthy. Let’s
wrote some code.</p>&mdash; Richard Schneeman (@schneems) <a
href="https://twitter.com/schneems/statuses/458968414267006976">April
23, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

You can watch the
[keynote](http://www.justin.tv/confreaks/b/522089408) and read his
follow up blog post titled [TDD is
Dead](http://david.heinemeierhansson.com/2014/tdd-is-dead-long-live-testing.html).
There is also a follow up
[interview](https://www.youtube.com/watch?v=Wp_tTfoCXYg&feature=youtu.be).

DHH's focuses primarily on "clear" code. He's concerned about over use
of patterns that make code more convoluted but easier to
test. He equates a lot of current happenings with peusdoscience. DHH
declares TDD is harmful and some sort of snake-oil. He says TDD hasn't
been effective for him and doesn't consider unit test obsession useful.
DHH recalls a bug in Basecamp that was not caught by tests even though
"everything was green." He suggest that people put more focus on high
level system tests. That was the general content. Unfortunately most
of the audience took away "TDD is useless" or "don't test." This is
unfortunate and angered people. Personally, I think DHH has an
aggressive style and I respect a leader's ability to make people think
or challenge ideas.

I think Yehuda said it best.

<blockquote class="twitter-tweet" lang="en"><p>ProTip: DHH always uses
strong, unequivocal language to make people think. More nuanced
language lets people sneak their biases in.</p>&mdash; Yehuda Katz
(@wycats) <a
href="https://twitter.com/wycats/statuses/458633389537771520">April
22, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

The "strong unequivocal language" missed the hidden undertones.

<blockquote class="twitter-tweet" lang="en"><p>If your TL;DR of my
talk and post on TDD was &quot;great, I don&#39;t have to write
tests!&quot;, your comprehension skills are inadequate. Level
up.</p>&mdash; DHH (@dhh) <a
href="https://twitter.com/dhh/statuses/459329011420647424">April 24,
2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

I do **agree** with DHH's primary message: unit test obsession is
harmful. If you do not have tests verifying system correctness you are
doing it **wrong**. This is where the Swedish concept of "lagom" is
paramount. "Lagom" is a Swedish words that emphasize the concept of
"just enough." Never too much, never too little. Unit test obsession
does not ensure the whole thing works. System test obsession does not
verify all intricate details. That's why you need "just
enough" of both. DHH included a slide from Kent Beck. Beck said he
tests enough to give him the required confidence. Lagom prevails again.

I do not know how Basecamp tests their product. DHH mentioned that
added a QA team just a year ago. I do not know if they are doing
acceptance tests with capybara. My preception from the talk was that
they had little to none. This is difficult to believe. Regardless he
hopes to go in that direction and make it easier to test Rails
applications at a user facing level. He proposed we call these things
"System Tests." Seems like a good name. The ideas were presented as
such to combat people who try to push unit test heavy suites.

<blockquote class="twitter-tweet" lang="en"><p><a
href="https://twitter.com/lgleasain">@lgleasain</a> <a
href="https://twitter.com/tehviking">@tehviking</a> <a
href="https://twitter.com/jm">@jm</a> I find a lack of good-coverage
integration tests to be far more damaging than a lack of
design-driven-by-tests</p>&mdash; Yehuda Katz (@wycats) <a
href="https://twitter.com/wycats/statuses/458695851192647680">April
22, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

TDD is far from dead. You can and should ignore the headlines. Start
by writing a system test from the furthest part out. This may be the
UI or simply an public API. Drive classes and more unit tests from
the high level functionality. It is not practical to specify 100% of
functionality in a system test. Use TDD to drive the relation and
interactions between objects. Make it green. Now you have a passing
system tests and a bunch of smaller tests. Refactor. Continue to add
more tests at various levels until you're confident everything is
correct. Ship. Anything else is wrong.

<blockquote class="twitter-tweet" lang="en"><p>I use <a
href="https://twitter.com/search?q=%23tdd&amp;src=hash">#tdd</a> only
when I understand the problem and have an inkling of a solution. Know
the <a
href="https://twitter.com/search?q=%23context&amp;src=hash">#context</a>
when <a
href="https://twitter.com/search?q=%23tdd&amp;src=hash">#tdd</a> works
for you. <a
href="https://twitter.com/search?q=%23railsconf&amp;src=hash">#railsconf</a></p>&mdash;
Declan Whelan (@dwhelan) <a
href="https://twitter.com/dwhelan/statuses/458973932977401856">April
23, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

Finally, don't be scared of patterns. Patterns are important. Do not
let DHH's words about patterns scare you away. The most important thing
to learn is when to apply patterns. Unfortunately this only comes with
experience. Patterns are not the be-all-and-end-all. They abstract
concepts that will improve software of varying levels of complexity.
Try them out and see what fits. What works for DHH & Basecamp may not
work for you. That's OK. Embrace it. Almost everything has multiple
answers. There is only one certainty: if you are not testing, then
you are doing it wrong.

Now I lave you with the rest of the internet's reaction:

@solnic's [TDD is Fun](http://solnic.eu/2014/04/23/tdd-is-fun.html)

<blockquote class="twitter-tweet" lang="en"><p>I do agree with <a
href="https://twitter.com/dhh">@dhh</a> on metrics though. Coverage
and other metrics means shit if your software doesn’t work. As simple
as that.</p>&mdash; Piotr Solnica (@_solnic_) <a
href="https://twitter.com/_solnic_/statuses/458733529267200000">April
22, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p>The fact that they had
a bug in basecamp despite great unit test coverage means that
integration/acceptance level testing was lacking</p>&mdash; Piotr
Solnica (@_solnic_) <a
href="https://twitter.com/_solnic_/statuses/458727041534554112">April
22, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p>TDD is about driving
your design through testing first. Using all kinds of tests with the
main focus on UNITS that you achieve EVENTUALLY</p>&mdash; Piotr
Solnica (@_solnic_) <a
href="https://twitter.com/_solnic_/statuses/458726548024344576">April
22, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p>DHH continues to make
context-free general arguments like <a
href="http://t.co/gXYiPdNC75">http://t.co/gXYiPdNC75</a> to drive the
direction of Rails.</p>&mdash; ¬ ∀ north carolina (@jcoglan) <a
href="https://twitter.com/jcoglan/statuses/458945748466671617">April
23, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p>Let me tell you about
the 2-hour 8-worker-cluster Rails system test suite I used to work on
some time.</p>&mdash; ¬ ∀ north carolina (@jcoglan) <a
href="https://twitter.com/jcoglan/statuses/458945412762968065">April
23, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p>Deeply bothered the
designer of my web framework is mixing up TDD with unit testing and
concluding the latter should be discouraged.</p>&mdash; ¬ ∀ north
carolina (@jcoglan) <a
href="https://twitter.com/jcoglan/statuses/458945245049544705">April
23, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p>Sometimes I suspect
that DHH doesn&#39;t like TDD because he inadvertently made it so
difficult for himself and others in Rails.</p>&mdash; Michael Feathers
(@mfeathers) <a
href="https://twitter.com/mfeathers/statuses/458948222732759040">April
23, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js"
charset="utf-8"></script>
