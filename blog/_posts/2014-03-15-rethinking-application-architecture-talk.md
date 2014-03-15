---
title: "Rethinking Application Architecture Talk"
layout: post
---

This is This is my script for my talk I gave at Wroclove.rb.  You can
find the slides on [speaker
deck](https://speakerdeck.com/ahawkins/rethinking-application-architecture).

-----

Yesterday Piotr gave a good talk on creating a legacy Rails
application in 1 easy step. Like many people I came to Ruby through
Rails. I was doing those _super_ repetitive CRUD PHP applications that
were essentially more user friendly versions of phpMyAdmin. Over the
years I wrote my fair share of absolutely embarrassing ruby code the
rails way. I think I wrote a gem called "ActsAsGodObject". I suffered
through gigantic applications and began to ask myself why was I even
using this damn thing anyway? Once the test suites start to take one
and a half hours, there's 179 total gems in the project, there's
ActiveRecord API calls consuming every classes, and pretty much every
other reason "rails rescue project consultancies" exist you really
have to re-evaluate your choices. Make no mistake, this talk is not
about Rails in any way. This talk is about how I learned to fix that
pain entirely.

It took me a very long time to arrive here. I learned much along the
way. Today I'm here to share my experience in the hopes of making
everyone in this room better software engineers. My primary goal is to
encourage all of you to rethink your application's architecture. This
talk will cover a lot of ground. Unfortunately I cannot show as much
code as I'd like, so please read my blog for much more in depth
technical discussion. Instead this talk will focus on the high level
concepts with minimal code examples. I don't think any of the ideas are
new. Each stands on its own and on the shoulders of many other
brilliant engineers. Hopefully everyone's heard of SOLID. We're lucky
enough to have Michael Feathers here. If you don't know who he is then
I suggest you google him. He coined mnemonic so all of us could
remember the important things more easily. It's also great he's here
because he can answer your questions after my talk. If you're here
right now Michael please raise your hand I'll buy you beer afterwords.

This conference is about challenging ideas. I challenge the
idea that the ruby community knows and understands how to architect
and design code bases. We do not respect SOLID principles. I think on
the level ruby community produces programs that ignore fundamental
architecture boundaries. This in turn creates more technical debt
which makes it harder for us to ship. This limits our capacity to meet
ongoing business needs--lest we forget this is our most important
responsibility. In order to address this problem we need to start from
beginning to arrive at a position where the application contains
proper boundaries and use of design patterns.

I think every application is generated through a big bang moment in
our heads. There is a moment when everything comes together and *poof*
a whole application pops out. We need to unpack the word
"application." What is an application? What does everyone think when
they start thinking about "new applications?" Is the first thought
towards: omg shiny? Or I can't wait to try out this new library. What
framework should I use? If those things hit home for then I hope you take
something away from this talk. None of those things are important. We
must understand that an application is a collection of use cases and
that's it--regardless of anything else.

As web developers we need to peel back the bullshit onion to get to a
point where we can focus **only** on business logic.

A use case represents business logic. It takes input from the user and
does something for them. It interacts with a host of other classes in
the system to enact the desired change. That is the single
responsibility principle at work. But what are these other classes?
These are the domain entities. They are the nouns in an application.
There are also adjectives, verbs, and prepositions. The use cases
arranges everything to create a meaningful sentence.

I mentioned that use cases use input from the user and do something
with it. Now we're faced with a question: how does _that_ happen for
the user?  Well there is this thing. It's called the delivery
mechanism. It takes the domain classes and exposes them to outside
world in a way that a human can understand and do something with. As
programmers we think the best delivery mechanism is for the user to
clone our repo, require our class then call a method. However this
wasn't arcane enough so the industry invented JavaScript/HTML/CSS. In
reality the delivery mechanism is the boundary between the human
interaction context and the domain logic. There's the word "boundary"
again. It's important. We must go deeper to understand its power.

Boundaries separate larger architectual concerns. Each concern is
another layer. Every application has at least two layers. There is the
Business Logic and Data layer. These boundaries are extremely
important because boundaries enables different subsystems to vary
independently of each other. This is to say either side of the
boundary can be replaced with another component and the wider system
is none the wiser. Aggressive boundary creation allows us to focus our
efforts on smaller more discrete units of code. This in turn increases
our ability to estimate, change, and meet real engineering
requirements. Hell it may even make us a little happier too.

Now that the problem domain is smaller it's easier to apply SOLID
principles, design patterns, and object roles. Let's turn our
attention back to the application layer. What things live in here?
Well this is where the magic happens. We know we have use cases and
domain entities. Domain entities is a very board term and it is on
purpose. Large systems should contain many different classes so it's
hard to categorize everything. However there a few common cases such
as forms, validators, models, and repositories. Let's go on a quick
tour of these objects.

Forms collect, sanitize, and model system input. They do context free
validations is the value less than 100. They coerce input into the
right type. They are border guards. A form object protects our
application from the outside world. They should be strict and ruthless
since once data passes through the border it is never checked again.

Next up: models. These classes encapsulating data and state. Methods
provide behavior. They are the nouns such as Customer, Project, or
User. If there are any rails fanatics in the audience if you thought
about ActiveRecord here you should definitely stop that. There is a
much better way. If you didn't then perhaps you already know what's
coming next. Actually, I think I see some people snickering to each
other in the back rows.

Unfortunately it's very hard for us programmers to think of data
without considering persistence. After all what good are the objects
if I can't get them back? This is dangerous in my experience because
it usually focuses on the _how_ and not on the _boundary_ between
access and persistence. We may ask questions like should I use a RDMS,
or what about a document store, key-value, or hell can elastic search
actually be my primary data store? All of these are important
questions, but they must be asked at the appropriate times. How many
times have we committed to one solution too early? Or realized we
needed a different implementation in certain scenarios? Or chosen an
ORM pushing persistence concerns up into application layer. This can
be a deadly mistake. We must build on abstractions and not
concretions.

It's fitting we arrive here actually. How many of us have ever asked
ourselves: how can I run my tests without the database? There is a
well known answer: introduce a boundary between data access and
persistence. This is arguably the most important decoupling you can
do. It was a turning point for me. Once I had my tests running against
memory style implementations there was no going back. I aggressively
created more boundaries. I did all of this to ensure that I could run
my tests without needing the outside world. It was the beginning of a
ports & adapters style architecture. Decoupling is not just about
tests. It allows us to defer important decisions (like the previous
data store questions) until we can make the right ones. Uncle Bob
Martin states this is the hallmark of a good architecture. There is a
design pattern that fits the bill perfectly: it's the repository
pattern.

Repositories are the interface to underlying data layer. Here's Martin
Fowler's definition:

> A Repository mediates between the domain and data mapping layers,
> acting like an in-memory domain object collection. Client objects
> construct query specifications declaratively and submit them to
> Repository for satisfaction. Objects can be added to and removed
> from the Repository, as they can from a simple collection of
> objects, and the mapping code encapsulated by the Repository will
> carry out the appropriate operations behind the scenes.
> Conceptually, a Repository encapsulates the set of objects persisted
> in a data store and the operations performed over them, providing a
> more object-oriented view of the persistence layer. Repository also
> supports the objective of achieving a clean separation and one-way
> dependency between the domain and data mapping layers.

You really couldn't ask for more could you. Now that's solved, time to
move on.

Next we move onto to validators. Validator implement more complex
validations. They may require state or more complex business rules.
Now, I know you'd love for me to just pull an example out of my hat
but as you can see I'm not wearing one. It's hard to give you an
example because validation logic is context & application specific so
that pretty much means my hands are tied. Just know that this role
exists and it will eventually materialize.

Finally use cases interact with all these objects to do something.
They combine stateless domain entities with state and enact change.
State can mean anything. In most cases it means who the current user
is. All of this information is passed in via the constructor. This
means these objects are easily testable: pass in the form and state,
then assert on the results and other side effects. This encourages a
clean separation between what the system actually does and how the
user interacts with it. This is extremely important as systems grow.

We've gone all the way down to the bottom and back to up. I mentioned
"user interaction". This is the delivery mechanism. The delivery
mechanism instantiates forms, handles state management in its given
medium, instantiates uses cases then executes them. It also handles
failures scenarios in a medium appropriate way.

So were left with two primary tiers: the user facing presentation
layer and application layer which contains all the business logic.
Naturally inside each there are more responsibilities. The
presentation layer will have a bunch of view objects for logic less
templates. It may have serializers to power a JSON API. It will
likely have middleware and a bunch of over stuff make its job easier.
Then in the application layer we have all previously mentioned objects
such as Forms, Uses Cases, Validators, Repositories, and various other
domain entities. The repository is a boundary between the domain
objects and the data layer. Hopefully all dependencies on the outside
world are replaced with boundaries. Need to talk to twitter? There's a
boundary there. What about sending an email? That's a boundary too.
All these decisions come together in testing. Want to test your data
layer? You can unit test that. Want fast tests? Swap the real
implementations for fake implementations. Everything is decoupled and
isolated. This puts us in a powerful position because we can leverage
the "O" in solid. The O means open for extension, closed for
modification. Now it's possible for us to compose more complex
behaviors by reusing our existing objects. This part is truly
eyeopening. Have a complex flow?  You can implement that by composing
two existing use cases. Try doing that with MVC.

Why aren't more people doing this? I think there's many reasons.
First, there are so many legacy applications that simply have to keep
functioning. It's not important to spend significant capital to
refactor them. Second, it's hard. Greenfielding projects is more
difficult because how much more upfront thought must be given to the
interface and protocols objects use to get things done. Third, I don't
think the community encourages people to think like this. The ruby
community encourages mindless over-reliance on gems and frameworks.
This usually creates applications that don't have any layering and are
essentially legacy applications from the first commit. All is not lost
though. You are here and hopefully learning something.

Now I have two resources for you. First if you have an existing
applications that you need to refactor so _then_ you can apply these
principles I recommend "Rails-Refactorings" by Andrzej. He does some
stuff with simple delegator that is down right magical. Second, if you
want to know how to get started greenfielding an application you
should check out my blog series on "The Joy of Design". These two
resources should help you attack the problem at both ends.

Now I open the floor for questions. Thank you.
