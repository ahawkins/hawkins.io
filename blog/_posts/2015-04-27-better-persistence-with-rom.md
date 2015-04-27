---
layout: post
title: "Better Peristence with ROM"
image: http://rom-rb.org/images/logo-nav.png
---

Data persistence is at the heart of most computer programs. The
program is pretty much junk if it cannot recall things put into it.
The data is more important when it comes to relating different bits of
it. In the past the RDMS was the one true way to manage data. Most
programming language ecosystems came up with design patterns like
active record, data mapper, and repository to make working with a RDMS
easier. Each of these patterns optimize for different architectural
concerns (such as business object & persistence coupling or trending
more towards CQRS). Now most programs deal with multiple input data
sources. More write outputs are increasingly common. These concerns
are amplified by the ever growing number of new data stores (Document
Stores, Graph Databases, and hosted solutions like DynamoDB). As
programmers we must decide how to to mix all the concerns,
requirements, and technological constraints into useful software.

I attempted to solve many of my persistence problems by using the
repository pattern. My [chassis][] library contains a general purpose
implementation of the pattern. I have been using the implementation
for roughly four years now. It has worked out well enough to reuse
across multiple projects and different data stores. The repository
pattern does an excellent job of separating concerns, but the it's the
programmer's responsibility to make everything work. I've enjoyed
working with my implementation for a few reasons.

1. There is no general purpose data access interface. The repository
	 adapter must implement all functionality required for the specific
	 problem domain. For example, there is no general query API. Each
	 selector is represented as a `Struct`. The struct contains all the
	 fields required to implement the given selector. This requirement
	 means I knew exactly what queries would go to the underlying data
	 store and that each had the appropriate things in place (like an
	 index).
2. Complete command/query implementation. The repository object has a
	 method for a specific responsibility. Need an aggregration across a
	 few entities filtered by some meta data? Easy, define the the
	 method and appropriate selector struct. No implementation details
	 leak across the boundary.
3. Switching persistence implementations. This was one of my favorite
	 features. I test drove my business objects, relations, and other
	 data store interactions using a simple array
	 implementation. This sped up the TDD cycle and gave me more
	 confidence in object collobration. This saved times because
	 implementing real persistence was always more complex.
4. Flexibility. I (personally) never felt limited by the abstraction.
	 I used the same code for manage objects in Redis, MonogoDB,
	 Postgres, and reading data from web services.

Naturally the implementation is not perfect. There are things that I
got wrong and have learned to work around. I made the mistake of
binding persistable objects to the repository via an `id` method. The
repository set the `id` after creation. If the `id` is set,
persistence operations are updates. This is a weird semantic that has
done more harm than good in the wrong run.

I also ended up writing serialization code over and over again.
Eventually I got sick of it and started using Base64 encoded blobs
with Marhsal dump/load. Writing serialization/deserialization code is
such a waste of time and it's horribly easy to make a mistake. The
complexity largely depends on the entities and data store. The
repository pattern is wonderful because it separate concerns.
Unfortunately a RDMS make this abstraction wonky. You may have to
duplicate entity attributes in a few places: the class itself, a
migration, serialization/deserialization, and in the queries
themselves. This was most painful part of my first implementation on
RadiumCRM and that code is (hopefully) not around so much anymore.

Also the code was largely only understood and extendable by myself. My
coworkers generally grasped the concept for writing queries and
adapters but more complex things never clicked. The end I was still
bound to the code.

All of these things must be weighed and measured. Key architectural
decisions tend to be long lived so it's important to get it right. How
you manage and interact with the data will ripple out into all areas
of the larger program. You must consider things like: how complex are
my domain and persistence requirements? Do I want separation between
reads and writes? What's the process for new new entity? What happens
then the data model changes? What happens if the data store doesn't
scale? How much code do _I_ want to maintain? How understandable is
this to current and future maintainers? Is any of this code actually
documented? Is it easier for me to implement a one-off persistence
layer for this domain?

I've been thinking about these questions ever since I decided to
fundamentally change how I architect applications. I started out by
switching active record for the repository pattern. This seemed like
the general solution to most problems. Now I think differently. I
think in general a data mapper with strong CQRS is the best solution
for most programs. The data mapper separates entities from persistence
(and the logic of each data store). The mapper also eliminates writing
serialization/deserialization code (tradeoff being that every
attribute is public). Immediately two large concerns are sorted out.
CQRS sorts the rest out. Luckily a few key members of the Ruby
ecosystem have put this problem on their back and produced exactly
what most programs need: [ROM][].

Recently the one and only [Piotr Solnica][piotr] (as you may
know one of the Ruby programmers I highly respect)
contributers have got the project moving in stride. I decided
to give ROM a go on a small project. It does everything my repository
implementation did with the upside of being _maintained_,
_documented_, an generally easy enough to use. ROM has all the
abstractions _exactly_ where they need to be. All the bits are well
thought out and their interplay is spot on. After a few hours it was
clear that I would replace chassis' repository with [ROM][].
You should look into [ROM][] if you haven't already.

ROM is wonderfully constructed because it has relations, mappers, and
commands. A relation is a dataset and abstracts a specific data store.
Commands manipulate the data store (e.g. CUD in CRUD). The mapper
(naturally) maps relations to their defined entities. ROM also
includes a high & low level interface. The high level interface is
great when there are simple queries.  The low level interface exposes
the relation directly. This makes it easy to define methods that
leverage the specific data store for things like aggregations or
requirements that don't map explicitly to entities.

Here is the code that made me excited about ROM. It's annotated with
comments to call out ROM specific things and things I like.

<script src="https://gist.github.com/ahawkins/92809d4ed467697480ed.js"></script>

My hat is off the ROM team. They've done an excellent job producing
something useful with the correct architectural abstractions. I'm
looking forward to using ROM the next time I do some Ruby work.

[piotr]: https://twitter.com/_solnic_
[ROM]: https://romrb.org
[chassis]: https://github.com/ahawkins/chassis
