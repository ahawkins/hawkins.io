---
title: "Repositories: Chassis Internals"
layout: post
---

I have already covered when and why to use a repository. The rest of
the series focus on writing and using them in practice. The posts will
use [Chassis](https://github.com/ahawkins/chassis) for all technical
examples from this point on so it makes sense to understand how the
Chassis implementation works.

The Chassis implementation has evolved since the initial
implementation. I have been refining it each time I use it a new
project learning from what works and what does not. It seems things
have settled and things are flexible in the right way.

The implementation is slightly different than ones you may have read
about. The repository object is a facade to a collection of objects.
The repository instance uses map to collect domain classes to a
manager class. The manager class handles all CRUD operations for that
class. The facade takes the domain class and operation and delegates
to correct manager.

I settled on this structure because it is easier to handle domain
class operations and it also flexible. One facade can encapsulate
persistence to multiple different mechanisms using different manager.
It is also create class specific facades as well. In short is possible
to represent all persistence in one facade or create class specific
facades. I prefer a single facade because a simple call to
`repo.clear` will wipe all data in tests.

In practice there are always three different objects in play. There is
the repository object, a class specific repo which defines custom
queries are other class specific read operations, and the object class
itself. The Chassis [README](https://github.com/ahawkins/chassis)
covers these concepts well enough. Here's an example. A `Post` class
delegates its persistence to `PostRepo`. `PostRepo` in turn if a thin
layer over the repository's interface.

That covers the concepts at a high level. Now let's turn to some code.
[`Chassis::BaseRepo`](https://github.com/ahawkins/chassis/blob/master/lib/chassis/repo/base_repo.rb)
is an abstract that all packaged repositories use. All operations
delegate to the `map`. The `map` object connects a domain class to a
persistence manager.
[`Chassis::Repo::RecordMap`](https://github.com/ahawkins/chassis/blob/master/lib/chassis/repo/record_map.rb)
provides the common interface for CRUD operations. Browse the
prepackaged repositories on
[github](https://github.com/ahawkins/chassis/tree/master/lib/chassis/repo).
You'll see they implement a storage specific map which delegates to
the simple implementation. The redis implementation stores serialized
record map instances in specific keys. The `PStore` implementation
works in the same way. This structure works out well for those
implementations. The same structure (but not exact implementation) can
be used for more complex stores.

There is one final bit of magic that is only useful in real world
scenarios. Chassis also includes a lazy association. This is an
interesting bit of code. It is a completely transparent proxy. It
completely mimics the associated class, so if you must ask `is_a?` and
`instance_of?` query methods things will continue to work. When a
method is called that is not implemented it will use the repository to
load the correct object then call the method. Its primary use case
serializing/deserializing/loading records to prevent unneeded calls to
the persistence mechanism.

I'll leave you with a gist with some real code to illustrate the
concepts.

<script src="https://gist.github.com/ahawkins/10583642.js"></script>

The next post is on using the public interface.
