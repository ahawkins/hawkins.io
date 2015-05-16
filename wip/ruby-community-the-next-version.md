---
title: "The Ruby Community: The Next Version"
layout: post
---

The Ruby community is and has been moving in the wrong direction for
some time. It has taken me quite some time to acknowledge this and
more time to specifically to pinpoint why and what can be done. The
community is facing large technical and mindset issues. I think we
must revalute them if we want to surive and thrive.

Most of my concerns are technical however there is a synergy between
technical choices and general mindset. My concern is the Ruby
community is creating a large amount of long term technical debt by
failing to produce libraries and progems that obey fundamentally sound
software design principles. Code across whole ecosystem is riddled
with large projects that do not respect architecture boundaries, or
overly coupled to many things, relies on global monkey patching of
third party code, and the list goes on. It's saddending to see so many
projects collapsing under technical debt at a high rate. There are
business models that exist to specifically clean up this mess. I
believe we can do better.

The current community mindset is not helping either. Ruby developers
are used to being spoonfed integrated solutions. The natural result is
to immediately reach for `gem install business-logic` configure
something and ship it. I'm finding it increasingly difficult to find
developers who have experience implementing business logic or let
alone more low level technical requirements. This is concering as a
developer and also as someone with hiring power. The long term effect
is that many Ruby developers can not to shoulder technical
responsiblity or code ownership. The other problem is that most
technical concerns are evaluated in the immediate short term instead
of the mid and long term.

Matz created Ruby to make programmers happy. He made programmers happy
by creating the superb `Enumerable` module, powerful metaprogramming
support, and a nice OO implementation peppered with the best
functional programming bits. Programmers were happy because they could
be produce working software quickly. Matz's initial guiding hand and
influence has stuck with us and created a culture. The culture of
pretty code over technical correctness. This is evident in
proliferation of DSLs instead of well designed and reusable APIs.
Ruby's metaprogramming support is the most powerful language feature.
Unfortunately it's routinely overused to create overly complexy and
opaque solutions.  But who's still happy? The net effect of all these
factors is that more developers are becoming unhappy Ruby programmers.

A conversation is starting in private circles. It's backroom chat
because most people do not want to come out and express concern or
distress over the happy Ruby land. It's unfortunate that it's not
happening in in public. There are passionate people who are interested
in improving the situation. It may be because people are scared to
broach the topic since it may be seen as biting the hand that feeds
them. It may also because the current thought leaders do not see it as
a problem--which is more concerning. Regardless people who feel
frustrated by the the same or different concerns need to voice their
opinion. These concerns are valid and you are not alone. Luckily there
is something we can do it about it.

The antitode is painful. I know because I tested on myself and I know
others have as well. It's drastic but we must act to improve the
ecosystem. If we do not change, then we cannot expect to ever improve.

First we need new community leadership. The same people have been
leading the conversation for some time. It's time to put an end to
that. The community needs strong new leadership based on more sound
technical principles. The next version of the Ruby community needs new
values as well.

* **Prefer well designed libraries** over monkey patching - In general
	reusable code does not need monkey patching.
* **Prefer smaller libraries** over larger ones - Small API surfaces
	are easier to integrate into large code bases and also enforce
	boundaries.
* **Explict** over implicit - programs are more easily
	maintained and understood when dependencies or side effects are
	explicit.
* **Prefer simplicity** over convenience - convenience comes at a
	cost. Writing some extra code yourself is not a problem.
*	**Prefer self composed stacks** over turn key solutions
* Focus on **mid to long term** concerns over immediate needs
* Design with instrumentation in mind - production code needs metrics
	to be taken seriously. Provide instrumentation interfaces instead of
	forcing developers to monkey patch libraries
* Lead by example - Demonstrate and teach others how to apply these
	values through open source, code review, and other techniques.

Second we need developers to embraces these values to write the next
generation of libraries. Most importantly they most be passionate and
motiviated enough to follow last value: teach others to produce to
produce better software.

Next we must use those libraries to create more technically sound
programs and applications with more long term technical concerns in
mind. This will allow us as engineers to create more maintainable
software that can continually adapt to changing business requirements
without fear.

After that we must drop the baggage from the current era. This must be
down by either replacing key components with one ones or simply
letting them die. They should be set as legacy concerns that are no
longer relevant.

I think this transformation is vital to Ruby's long term surivial.
I'm convinced that adopting these values can be build the next version
of the Ruby community. I've seen them transform my own development
habits and seen independent transformations happen in others as well.
These values are important as they are useful. So will you join in me
creating the next version of the Ruby community?
