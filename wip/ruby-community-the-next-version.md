---
title: "The Ruby Community: The Next Version"
layout: post
---

The Ruby community is and has been moving in the wrong direction for
some time. It has taken me some time to acknowledge this and more time
to pinpoint why and what can be done. The community is facing large
technical and mindset issues. I think we must revaluate ourselves to
survive and thrive.

The technical choices and mindset that reinforces them is creates
large amounts of long term technical debt. The ecosystem is not
producing libraries and programs that obey fundamentally sound software
design principles. The ecosystem is riddled with large large projects
that do not respect architecture boundaries, or overly coupled to many
things, relies on global monkey patching of third party code, and the
list goes on. It's sad to see so many projects collapsing under
technical debt at a high rate. Businesses are also suffering due to
bad engineering practices. There are business models that exist to
specifically clean up this mess. We can do better.

Ruby developers are used to being spoonfed integrated solutions. May
new and intermediate developers immediately reach for `gem install
business-logic` configure something and ship it. I'm finding it
increasingly difficult to find developers who have experience
implementing business logic or let alone more low level technical
requirements. This concerns me as a developer and also as someone with
hiring power. The long term effect is that many Ruby developers can
not shoulder technical responsibility or code ownership. The secondary
problems is most technical concerns are evaluated in the immediate
short term instead of the mid and long term. How many of us consider
ramifications of using a library or other decision 6 months from now,
or even two years from now? This pattern only perpetuates technical
debt.

Matz created Ruby to make programmers happy. He made programmers happy
by creating the superb APIs (like `Enumerable` module), powerful
metaprogramming support, and true OO implementation peppered with the
best functional programming bits. Programmers were happy because they
could produce working software quickly. Matz's initial words have
stuck with us and influenced our culture. Today the culture prefers
pretty code over technical correctness. This is evident in
proliferation of DSLs instead of well designed and reusable APIs.
Ruby's metaprogramming support is the most powerful language feature.
Unfortunately it's routinely overused to create overly complex and
opaque solutions. But who's still happy? The net effect of all these
factors is that more developers are becoming unhappy Ruby programmers.

A conversation is starting in private circles. It's a backroom chat
happening at conferences and small corners of the internet. There are
mumbles of dissatisfaction and wanting for something different. But it
is a private mumble. Why is it private? It may be because people are
scared to broach the topic since it may be seen as biting the hand
that feeds them. It may also because the current thought leaders do
not see it as a problem--which is more concerning. It is unfortunate
that is not more public conversation. There are passionate people
interested in improving the situation. Regardless people who feel
frustrated need to voice the their opinions. The concerns are valid
and you are not alone. The issues must be brought to light so they can
be address and fixed.

The antidote to our current ails is painful. It requires a complete
reorientation. This is not easy. I know because I have tested it on
myself and I know others have as well. It is drastic but we must act
now. There will never be a better Ruby ecosystem if we do not.

Experienced developers must lead by example to create small well
designed libraries that use simple and explicit code constructs to
compose larger stacks capable of sustaining development across long
time periods. We must actively encourage better engineering practices
among our peers and actively discourage inadequate technical
solutions. We must teach beginner and intermediate developers how to
avoid these pitfalls so they in turn can teach others to build more
fundamentally sound solutions.

These changes will slowly chip away at many of the issues plaguing us
today. We will emerge stronger, better, and more informed version of
the Ruby community. This transformation is vital to Ruby's long term
survival. I'm convinced that adopting this way can be build the next
version of the Ruby community. It transformed my own development
habits and I have witnessed independent transformations happen in
others as well. Use these points to guide your decision making:

* Actively minimize dependencies and carefully audit the ones you
	intend to keep.
* **Prefer simplicity** over convenience - convenience comes at a
	cost. Writing extra code yourself is not a problem.
* **Prefer Explict** over implicit - programs are more easily
	maintained and understood when dependencies or side effects are
	explicit.
* **Prefer well designed libraries** over monkey patching - In general
	reusable code does not need monkey patching.
* **Prefer smaller libraries** over larger ones - Small API surfaces
	are easier to integrate into large code bases and also enforce
	boundaries.
*	**Prefer self composed stacks** over turn key solutions
* Architect with strong boundaries in mind
* Focus on **mid to long term** concerns over immediate needs
* Lead by example - Demonstrate and teach others how to apply these
	values through open source, code review, and other means.

Will you be part of the next version of the Ruby community?
