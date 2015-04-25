---
layout: post
title: "On Persistence: New Beginnings"
---

Data persistence is at the heart of most computer programs. The progam
is pretty much junk if it cannot recall things put into it. The data
is more important when it comes to relating different bits of it. In
the past the RDMS was the one true way to manage data. Most
programming language ecosystems came up with libraries and patterns
for making working with a RDMS easier such as the active record, data
mapper, and repository patterns. Each of these patterns optimize for
different architectual concerns (such as business object & persistence
coupling or trending more towards CQRS). Now most programs deal with
mulitple input data sources and more write outputs are increasingly
common. These conerns are amplified by the ever growing number of new
data stores (Document Stores, Graph Databases, and hosted solutions
like DynamoDB). As programmers we must decide how to to mix all the
conerns, requirements, and technological constraints into useful
software.

I attempted to solve many of my persistence problems by using the
repository pattern. My [chassis][] library contains a general purpose
implementatino of the pattern. I have been using the implementation
for roughly four years now. It has generally worked out well enough to
continue resuse across multiple projects and different data stores.
The repository pattern does an excellent job of separating concerns,
but the it's the programmer's responsibility to make everything work.
I've enjoyed working with the repository pattern (specifically my
implementation in Chassis) for a few reasons.

1. There is no general purpose interface. The repository adapter must
	 implement all functionality required for the specific problem
	 domain. For example, there is no general query API. Each selector
	 is represented as a `Struct`. The struct contains all the fields
	 required to implement the given selector. This requirement means I
	 knew exactly what queries would go to the underlying data store and
	 that each and the appropriate things in place (like an index).
2. Complete command/query implementation. The repository object has a
	 method for a specific responsibility. Need an aggregration across a
	 few entities filtered by some meta data? Easy, define the the
	 method and appropriate selector struct. No implementation details
	 leak out of the object.
3. Switching persistence implementations. This was one of my favorite
	 features. I test drove my business objects, relations, and other
	 data store interactions using a simple in memory array
	 implementation. This sped up my TDD cycle and ensured confidence in
	 the object collobration before taking the time to write more
	 complex persistence implementation.
4. Flexiblity. I (personally) never felt limited by the abstraction. I
	 used the same code for manage objects in Redis, MonogoDB, Postgres,
	 and reading data from web services.

Naturally the implementation is not perfect. There are things that I
got wrong and have learned to work around. I made the mistake of
binding persistable objects to the repository via an `id` method. The
repository set the `id` after creation. If the `id` is set,
persistence operations are updates. This is a werid semantic that has
done more harm than good in the wrong run. I also ended up writing
serialization code over and over again. Eventually I got sick of it
and started using Base64 encoded blobs with Marhsal dump/load. Writing
serialization/deserialization code is such a waste of time and it's
horribly easy to make a mistake. The complexity largely depends on the
entities and data store. The repository pattern is wonerful because it
separate concerns. Unfortunately a RDMS make this abstraction wonky.
You may have to duplicate entity attributes in a few places: the class
itself, a migration, serialization/deserialization, and in the queries
themselves. This was most painful part of my first implementation on
RadiumCRM and that code is (hopefully) not around so much anymore.
Also the code was largely only understand and extenable by myself. My
coworkers generally grasped the concenpt for writing queries and
adapters but more complex things never clicked so in some ways I was
bound to the code.

All of these things must be weighed and measured. Key architectual
decisions tend to be long lived so it's important to get it right. How
you manage and interact with the data will ripple out into all areas
of the larger programs. So you must consider things like: how complex
is my domain and persistence requirements? Do I want seperation
between reads and writes? What happens if I need to a new entity? What
happens then the data model changes? What happens if the data store
doesn't scale? How much code do _I_ want to maintain? How
understanable is this to current and future maintainers? Is any of
this code actually documented? Is it easier for me to implement a
one-off persistence layer for this domain?

I've been thinking about these questions ever since I decided to
fundamentally change how I architect applications. I started out by
switching active record for the respository pattern. This seemed like
the general solution to most problems. Now I think differently. Now I
think that in general a generic data mapper with strong CQRS is the
best solution for most programs. The data mapper separates entities
from persistence (and the logic of each data store). The mapper also
eliminates writing serialization/deserialization code (tradeoff being
that every attribute is public). Immediately two large concerns are
sorted out. A well done CQRS implementation sorts all the rest out. It
creates a specifc interface for asking for different data and another
for commands. Straight away another large set of concerns fall away
and whole class of problems never enter the picture. Luckily the a few
key members of the Ruby ecosystem have put this problem on their back
and produced exactly what most programs need: ROM.

[ROM] (or Ruby Object Mapper) is new evolution of the work on fabeled
DataMapper 2. The project has long history that I will not recount
here. Recently the one and only [Piotr Solnica][piotr] (as you may
know one of the Ruby programmers I highly respect) and all the
contributers have finally got the project moving in stride. I decided
to give ROM a go on a small project. It does everything repository
implementation did with the upside of being _maintained_,
_documented_, an generally easy enough to use. ROM has all the
abstractions _exactly_ where they need to be. All the bits are well
thought out and their interplay is spot on. After a few hours it was
clear to me that I would not use the chassis code anymore and use ROM
for all the things. I can tell from the construction that Piotr and I
are thinking about persistence problem is similar ways. Also my
experience working without the ORM crutch made transitiong to ROM a
trivial experience. You should look into ROM if you haven't already.

ROM is wonerfully construct because it has relations, mappers, and
commands. Together the tree make implementing all persistence concerns
a breeze. A relation is a dataset. The relation is also the
abstraction of the specific data store. Commands manipulate the data
store (e.g. CUD in CRUD). The mapper maps relations to their defined
entities. ROM also includes a high & low level interface. The high
level interface is great when there are simple reads or other straight
forward reads. The low level interface exposes the relation directly.
This makes it easy to define methods that leverage the specifc data
store for things like aggregrations or requirements that don't map
explicitly to entities.

Here is some code that got my excited about ROM.  I've annotated with
comments on things I especially like.

My hat is off the ROM team. They've done an excellent job on producing
something useful with the correct architectual abstractions. I'm
looking forward to using ROM the next time I do some Ruby work.

[pitor]: https://twitter.com/_solnic_
[ROM]: https://romrb.org
