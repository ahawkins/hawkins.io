---
title: "The Ruby Community: The Next Version"
layout: post
---

The Ruby community is and has been moving in the wrong direction for
some time. It has taken me quite some time to acknowledge this and
more specifically to pinpoint why and what we can do it about. The
community is facing large technical and mindset issues. I think we
must revalute them if we want to surive.

Most of my concerns are technical however there is a synergy between
technical choices and general technical mindset. My concern is that on
the level the Ruby community does not produce libraries or programs
that obey fundamentally sound software design principles. This creates
a huge long term technical debt across the whole ecosystem through
poorly constructed software that does not respect architecture
boundaries, or overly coupled to many things, relies on global monkey
patching of third party code, and the list goes on. It's saddending to
see so many projects collapsing under technical debt at a high rate.
There are business models that exist to specifically clean up this
miss. This is unfortunate because we can do better.

The community mindset is not helping here. Ruby developers are used to
being spoonfed integrated solutions for them. The natural result is to
immediately search for `gem install business-logic` configure some
thing and ship it. I'm finding increasingly difficult to find
developers who have experience implementing business logic or let
alone more level technical requirements. This is concering as a
developer and also as someone with hiring power. The long term effect
is that many Ruby developers can not to shoulder technical
responsiblity or code ownership. The other problem is that most things
are evaluated in the immediate short term instead of the mid and long
term costs of key technical solutions.

Matz created Ruby to make programmers happy. He made programmers happy
by creating the superb `Enumerable` module, powerful metaprogramming
support, and a nice OO implementation peppered with the best
functional programming bits. Programmers were happy because they could
be productive pretty quick. Matz's initial guiding hand and influcence
has stuck with this. Over the course of time this created a culture of
preferring code that looks nice and makes people happy at the cost of
technical correctness. This is evident in proliferation of DSLs
instead of well designed and reusable APIs. Ruby's metaprogramming
support is the most powerful language feature. Unfortunately it's
routinely overused to create more complex and more opaque solutions.
But who's still happy? The net effect of all these factors is that
more developers are becoming unhappy Ruby programmers.

This conversation is happening in many different private circles. It's
unfortunate that it's not happening in public. That may be because
people are scared to broach this topic since it may be seen as biting
the hand that feeds them. It may also because the current thought
leaders do not see it as a problem--which is more concerning.
Regardless people who feel frustrated by the the same or different
concerns need to voice their opinion. These concerns are valid and you
are not alone. There are people who want to work together to tackle
these issues and improve the situation. Luckily there is something we
can do it about it.

The antitode is painful. I know because I tested on myself and I know
others have as well. It's drastic but we must act to improve the
community. If we do not some of the best developers will leave to work
in areas that are simply more technically sound.

First we need new community leadership. The same people have been
leading the conversation for some time. It's time to put an end to
that. The community needs strong alternate leadership based on more
sound technical principles. The next version of the Ruby community
needs alternate values as well.

* **Prefer well designed libraries** over monkey patching - In general
	reusable code does not need monkey patching. This will also reduce
	the amount of monkey patching.
* **Prefer smaller libraries** over larger ones - Small API surfaces
	are easier to integrate into large code bases and also enforce
	boundraries.
* **Explict** over implicit - programs are more easily
	maintained and understood when dependencies or side effects are
	explicit.
* **Prefer simplicity** over convinence - convinenance comes at a
	cost. Writing some extra code yourself is not a problem.
*	**Prefer self composed stacks** over turn key solutions
* Focus on **mid to long term** concerns over immediate needs
* Demonstrate and teac others how to apply these values
* Ignore code makes `require` unworthy; ignore autoloading at all
	costs.

------------------------------------------------------------------

Here is the junk. Above this line kinda makes sense. Here is just
random notes and some bullshit. There's probably much more to say, but
just writing this was a struggle. Things to focus on:

* building a new version of the community
* creating a bubble where these ideas can surive and thrive
* ideas of bringing people over to this way of thinking
