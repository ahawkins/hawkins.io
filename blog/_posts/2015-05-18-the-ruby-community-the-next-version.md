---
title: "The Ruby Community: The Next Version"
layout: post
---

The Ruby community is and has been moving in the wrong direction for
some time. It has taken me some time to acknowledge this and more time
to pinpoint why and what can be done. The community is facing large
technical and mindset issues. We must reorientate ourselves to
survive and thrive.

The technical choices and mindset that reinforces them create
large amounts of long term technical debt. The ecosystem is not
producing libraries and programs that obey fundamentally sound software
design principles. The ecosystem is riddled with large projects
that do not respect architecture boundaries, or are overly coupled to many
things, rely on monkey patching third party code, and the
list goes on. It is sad to see projects collapsing under
technical debt at a high rate. Businesses are also suffering due to
bad engineering practices. There are business models that exist to
specifically clean up this mess. We can do better.

Ruby developers are used to being spoonfed integrated solutions. Many
new and intermediate developers immediately reach for `gem install
business-logic`, expect to configure something then ship. This creates
a cycle of focusing on immediate needs and not long term sustained
development. How many of us consider ramifications of using a library
or other decision 6 months from now, or even two years from now? The
long term result is many Ruby developers cannot shoulder technical
responsibility or code ownership. I'm finding it increasingly
difficult to find developers who have experience implementing business
logic, low level technical requirements, or cannot survive without
frameworks.

Matz created Ruby to make programmers happy. He made programmers happy
by creating superb APIs (like the `Enumerable` module), powerful
metaprogramming constructs, and a true OO implementation peppered with
the best functional programming bits. Programmers were happy because
they could produce working software quickly. Matz's initial words have
stuck with us and influenced our culture. Today the culture prefers
pretty code over technical correctness. This is evident in
proliferation of DSLs instead of well designed and reusable APIs.
Ruby's metaprogramming support is the most powerful language feature.
Unfortunately it is routinely overused to create overly complex and
opaque solutions through implicit dependencies. All of these factors
are turning developers into unhappy Ruby developers.

A conversation is starting in private circles. It is a backroom chat
happening at conferences and small corners of the internet. There are
mumbles of dissatisfaction and wanting for something different. But it
is a private mumble. Why is it private? It may be because people are
scared to broach the topic since it may be seen as biting the hand
that feeds them. It may also because the current thought leaders do
not see it as a problem--which is more concerning. It is unfortunate
that is not more public conversation. People need to voice their
opinions so we can work together to improve.

The antidote is painful. It requires a complete reorientation. This is
not easy. I know because I have tested it on myself and I know others
have as well. It is drastic but we must act now. There will never be a
better Ruby ecosystem if we do not.

Experienced developers must lead by example to create small well
designed libraries that use simple and explicit code constructs to
compose larger stacks capable of sustaining development across long
time periods. We must actively encourage better engineering practices
among our peers and actively discourage inadequate technical
solutions. We must teach beginner and intermediate developers how to
avoid these pitfalls so they in turn can teach others to build more
fundamentally sound solutions.

These changes will slowly chip away at many of the issues plaguing us
today. We will emerge stronger, better, and more informed community.
I am convinced that adopting this way can build the next
version our community. It transformed my development
habits and I have witnessed independent transformations in
others. We must use these points to reorientate ourselves:

* **Prefer simplicity** over convenience - convenience comes at a
	cost. Writing extra code yourself is not a problem.
* **Prefer explicit** over implicit - programs are more easily
	maintained and understood when dependencies or side effects are
	explicit.
* **Prefer smaller libraries** over larger ones - Small API surfaces
	areas are easier to integrate into large code bases and also enforce
	boundaries.
* **Prefer code open for extension** instead of modification - Well
	designed code does not need monkey patching
*	**Prefer self composed stacks** over turn key solutions
* Focus on **mid to long term** concerns over immediate needs
* Architect with strong boundaries in mind
* Actively minimize and audit your dependencies. Do not blindly trust
	the other's work.
* Lead by example - Demonstrate and teach others how to apply these
	values through open source, code review, and other means.

Will you reorientate yourself and build the next version of the Ruby
community?

_P.S._: This post and the wider ruby ecosystem is discussed in a great
[podcast][]!

[podcast]: http://rails-refactoring.com/podcast/
