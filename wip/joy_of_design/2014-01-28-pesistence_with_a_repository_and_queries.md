---
title: "Persistence with a Repository and Query Patterns"
layout: post
---

Talking about the day layer is inevitable. I saved the least important
part for last. I say least important because this entire layer is an
implementation detail. The application could not care less about what
happens behind the scenes. Conversely this could also be the most
important thing because of how important the boundary is. **The
boundary between the data and entities is the most important boundary
in the entire system.** Something simply provides the needed entities.
The caller is completely unaware of how they got there. 

This is about more than that. It's about adopting a new perspective.
How many applications are so caught up with the database? How did the
database become this thing that managed to litter its concerns across
an entire application? Imagine if domain objects had `to_html`
defined. How could that ever be allowed? Yet we constantly allow its
semantics to cross layers. The fact of the matter is I don't give a
shit about the database. I don't even want to know it's there--let
alone how the hell it does its job. This is why the boundary is so
important. Separate entities from persistence. This is the one true
way. Removing it promises pain. Using a repository has honestly made
me a happier programmer. I'll sum up the most important parts in no
particular order.

* Having a boundary between objects and persistence allows each side
  to evolve independently.
* The storage mechanism can be switched out with confidence (read: use
  memory in tests instead of a slower persistence mechanism)
* All data access goes through a single interface. This is
  great choke point caching and other optimizations.
* All queries are made through a standard interface and into the
  repository. It is **impossible** for implementation details to leak
  into other parts of the applications.
* Easy to persist different models in use case specific data stores.
  Need a simple key-value store? Implement part of the repository
  adapter using Redis. Other parts can be files, RDMS's or even as
  Uncle Bob puts it: "battery packed remote controlled writing
  machines."
* Specific queries can be implemented in faster ways. Part of Radium
  stores object graphs in views for ultimate speed. This is implemented
  using a separate code path for single object queries and graph
  queries. The semantics are all encapsulated in a single class.
  No details leak out.
* Persistence implementations can be unit tested.

The post has "repository" pattern in the title, so I haven't stated it
directly. Either way the repository pattern makes all this possible.
Avdi mentioned these patterns in his review on my paper. He said he
had not seen a use for them in his work. He also said that not every
application needs them. Some applications are small and don't need
such structure. I think all applications continue to grow like
viruses. I figured I would just start with this and see what happens.
Having the structure in place form the beginning would pay off huge in
the future. I went from using _only_ ActiveRecord (and thusly the
pattern itself) to repository + query. The results have been
wonderful. I was concerned it would feel awkward in smaller
applications. I'm pleased to say that it does not. I do everything
this way these days. It makes all things much better. If I cannot
convert you to a full blown repository, then I suggest you take a look
at the [data mapper
pattern](http://www.martinfowler.com/eaaCatalog/dataMapper.html).
Whatever you actually do you use, respect the boundary. Keep entity
access separate from persistence. This will change everything for you.

## Using The Repository

Here is the [repository
pattern](http://martinfowler.com/eaaCatalog/repository.html) according
to the brilliant Martin Fowler from Patterns of Enterprise
Architecture:

> A Repository mediates between the domain and data mapping layers,
> acting like an in-memory domain object collection. Client objects
> construct query specifications declaratively and submit them to
> Repository for satisfaction.  Objects can be added to and removed
> from the Repository, as they can from a simple collection of
> objects, and the mapping code encapsulated by the Repository will
> carry out the appropriate operations behind the scenes.
> Conceptually, a Repository encapsulates the set of objects persisted
> in a data store and the operations performed over them, providing a
> more object-oriented view of the persistence layer. Repository also
> supports the objective of achieving a clean separation and one-way
> dependency between the domain and data mapping layers.

The repository object provides methods and delegates to an
implementation. Everyone likes to implement patterns a little
differently. There is one global `Repo` class. All the methods take a
class as the first argument. All methods pass the class and other
arguments down to the implementation. The
implementation handles the `CRUD` logic. It tedious to pass
around the `class` argument everywhere. The next step is to create a
`CustomerRepo` or `AdRepo`. The class specific repos call the global
`Repo` with the correct `class` argument. This way classes can
interact with appropriately named repository. The `Repo.backend` applies
to all the `XXXRepo` classes. However the `CustomerRepo` can have its
own implementation if required. I haven't had that use case yet so I
stick with one implementation for all the objects. But it would be
possible to put an `Ad` in elastic search or key/value style objects
in redis.

Here is the repository itself along with a simple in memory
implementation.

<script
src="https://gist.github.com/ahawkins/2779c646a604b21bd1b2.js"></script>

No need for gems here!

## Integrating with Entities

Now that persistence is separate, there needs to be a way for entities
to interact with the repository. The description says the objects are
"added to the repository." I did not like this code: `repo <<
some_object`. I decided to go with a different route. I have a
`Persistence` module. It defines an `id` method. This is required by
the repository. It also defines a `save` method which delegates to the
proper repository. A `new_record?` method is added as well.

<script
src="https://gist.github.com/ahawkins/0c3eb4149ab41ca3e4b7.js"></script>

Now an entity can simply be saved or created. It makes the code easier
to work with in use cases. I don't like having references to top level
repository constants all over the code. This keeps the code clean and
loosely coupled.

## Real World Examples

As mentioned earlier, I have top level constants for each entity repo.
That class defines methods for handling queries. The `query` method is
never called directly. Queries are simple `Struct` classes. They
include all the data to execute the query. There is no "catch all"
query. Everything is explicitly defined. I like this because it keeps
all the data access calls defined and understandable. It also ensures
there is only one way to access data: through a high level interface.
Once the queries are there, I define the appropriate query methods in
the adapter and that's a wrap. Here's some real world code.

<script
src="https://gist.github.com/ahawkins/9168491345aafdbd3d8a.js"></script>

## Wrapping It Up

Implementing the adapter is the only thing left. Unfortunately I can't
help you there because that's implementation specific. I will say this
though. If you are using an RDMS, then use
[sequel](http://sequel.jeremyevans.net) for the adapter. Also, **do
not** implement a real adapter until the very last minute! It's always
surprising how quickly data models can change before launch! Stay with the
in memory implementation until all the concepts are there. There is
**nothing** to gain by implementing persistence early. Who knows, you
might not even need it. A good architecture allows you to defer
important decisions. The boundaries do just that.
