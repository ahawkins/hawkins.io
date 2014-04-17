---
title: "Repositories: When & Why"
layout: post
---

Every software architecture decision is about trade-offs. We asses the
current need and try to predict what's around the corner. It's not
about making the right decision all the time, but more about staying
flexible and shipping end of the day. Honestly you have a great
responsibility. Code may live for years, make or break the business.
We, as professional software engineers, weigh all factors and make
the best decision.

Unfortunately there is no globally correct answer. Programmers know
the answer is "it depends" regardless. There are always scenarios and
circumstances that force us to re-evaluate our position and accept
other trade-offs. This post is about bringing trade-offs into focus.

The repository pattern is not complex. There is an object. That object
handles the communication of objects across the boundary between
application and persistence layers. It separates domain objects from
their persistence. It requires a few moving parts. There are
"selectors" (according to Fowler's definition) that define criteria
for finding objects. The repository resolves the selector and returns
the correct objects. A "selector" can be anything. It can be a complex
query or a unique identifier. The repository provides a few things out
of the box: possibly to switch persistence implementations per domain
class or for all objects, the larger application accesses objects via
a high level query interface, and can swap persistence implementation
whenever you like (read: no slow persistence in tests).

It is easier to show examples of when not to use this instead of where
it makes more sense. The repository pattern requires a significant
mind shift in how you approach writing and designing the application.
Not every application requires this.

## Case 1: Minimal Complexity

There are complex applications, conversely there are trivial
applications. Think a blog vs an ERP system. There are certain
inflection points in software development where the complexity changes
and you're forced change architecture. I cannot pinpoint them, but a
repository is not needed for trivial applications.

I maintain a web service responsible for proxing a bunch of payment
gateways. There is one object that must be persisted. I used Sequel
and `Sequel::Model`. `Sequel::Model` is an implementation of the
Active Record pattern. There is no benefit in decoupling persistence
from objects because the object has no logic of its own--it is just a
database row.

The repository is great for preventing low level semantics from
leaking into the wider application. In this case, there is nothing to
really leak out. There are minimal calls to the Sequel query API (and
those are encapsulated by my own public methods). This is simple way
to get repository like query separation without going whole hog.

In this case it is still possible to decouple the tests from the
database. Sequel supports many different SQL implementations. This
application's tests run using in-memory SQLite. That's not fully
decoupled, but it's going to be faster than running against MySQL.

Looking at all of these things, it is safe to say that the application
is trivial enough to apply the ActiveRecord pattern with proper
safeguards. Introducing a repository would be a net negative here.

## Case 2: Too Many Leaky Abstractions

Imagine an application where persistence knowledge has spread across
the entire code base. Classes know about database columns and
everything knows about everything. You may call this NSA architecture.
Things that should know nothing know everything. Here are some smells
of NSA architecture:

* Classes other than the ORM backed class are using the ORM's API
* Data is loaded at arbitrary places in the code place
* Classes behavior depends on private persistence level details

Applying the repository pattern here is a fatal mistake. These
applications require a significant refactoring & restructuring to
move concerns to the right place. This may mean replacing calls
to an ORM's query API with named methods, creating query
objects, changing access scope, and a bunch of other things. In these
cases the prerequisite code cleanup is more beneifical than
introducing a new architectural pattern.

## Case 3: You're Not Knowledgeable Enough

Implementing the repository from the ground up requires significant
knowledge. You must understand how different layers fit together, how
they are dependent on each other, and what & where data passes between
them. You must also have low level knowledge of our data store. If you
are thinking about using an RDMS and you have never written SQL then
you should back off. If you're only experience is with ORM's you may
have problems planning internal structure. I am not stating that you
**must** write SQL by hand if you want to use an RDMS, but the point
is that you **can** write SQL because you are working at that level.
Naturally you may create an implementation on top of an ORM (such as
ActiveRecord or Mongoid) but that will limit you. The
repository pattern optimizes two different interfaces. First, there is
a high level data access application interface. It is not concerned
with how things happens. Second, lower level data store API are
accessible internally. This means you can and should take advantage
of the data store special features (like HStore in Postgres) or
representing some queries as views. Many things are possible at this
level and you must be comfortable working here.

## Case 4: A Mapper Fits Better

You know about the active record pattern, but have you heard of the
data mapper pattern? A data mapper handles mapping objects into one
one or more data sources. The mapper has a declaration (what and
where) and another part to take the mapping and provide objects. Due
to this decoupling there are usually different implementations (in
memory or RDMS backed). This may be enough for you. A data mapper
also allows you to connect data from multiple sources to the same
object. You can do this with a repository if you write it yourself,
but you should get it out of the box with a data mapper. Data mappers
are useful tool and may get you as far as you need to go without the
manual work required to implement a repository.

Time to move onto the cases when you should consider this approach.

## Case 1: High Complexity

This case is sort of a cop-out because it is the other side of the
inflection point mentioned in the first case. I cannot tell you
exactly where inflection point is, but here are smells you are
getting close:

1. Increasing number of persisted classes
2. Increasing number of custom queries
3. Application layer requiring changes in data layer

Essentially, is the complexity giving you serious pain in maintaining
the application?

## Case 2: Complex Legacy Data & Migration Scenarios

In my day job we need to read and migrate data from an old MongoDB
database. A data mapper is impractical for our case. There is a lot of
manual work and edge case handling. It turns out that a repository was
the perfect fit. It encapsulated all the semantics of reading data in
the old format and spitting out the correct domain objects. The
classes could also be tested in isolation. The legacy repository only
does reading, writes are delegated to an upstream repo. The upstream
repo is the "modern" one. It does all its writes to a new cluster in a
new format. All of this is transparent to the legacy reader.

## Case 3: More Productive Greenfielding

You do not know to do at at the start of a new project.  You may have
some idea about features or potential domain classes, but you are not
certain what data will be where or how it will be used. There are only
vague theories waiting to be proven by tests. Flexibility is key at this
stage. Thinking in DB tables, collections, or redis keys is harmful.
All of these things are implementation details. A memory backed
repository works perfectly in this case. Start writing classes.
Declare `attr_accessors`. Send the object to the repository to persist
it. Write tests. Develop in freedom. Figure out how the objects
interact and what data belongs together, then use that information to
write a better data layer. Don't let the data layer constrain you.

## Case 4: Use Case Specific Persistence

Most Applications no longer get data from a single source.
Applications are keeping data in an RDMS, probably putting simple data
in Redis, and random blobs into some document store. A repository is a
great way to encapsulate these concerns. You may create a per-class
implementation, or decide to wrap it all up in a single repository.
Either way, since the repository enforces true separation of
persistence and data access you can implement them separate from the
larger application.

## Case 5: Data Required from Remote Web Services

A strange thing happens when an application becomes dependent on a web
service. All of a sudden we realize something is wrong. We can't test
like this! It doesn't make sense to stub HTTP calls everywhere.  This
is horrible! I've seen this in myself and from other developers. This
is a pain point most of us have been exposed to. It is usually
impossible to test against these things so we need start thinking
straight. The solution is to separate data objects from how they are
retrieved--not the other way around. Consider you are doing reads from
some API. Naturally you don't want to call out to the API in your
tests but you need the data. A repository and an memory implementation
will do perfectly. Now you can create an HTTP API implementation and
unit test that separately. If you are currently using VCR, request
stubbing, or some other inadequate solution you should consider this.

Now that some anti-use cases and use cases have been covered, I'll
leave you with a simple list of trade offs.

Pros:

* clear separation of data access from data storage
* run tests against any implementation (fast tests with memory, CI
  testing against real persistence)
* possible to unit tests persistence mechanisms
* all data related changes are localized to a single unit of code
* easier to develop new applications because persistence can be
  ignored
* can use data store to fullest extent

Cons:

* must maintain your own data layer
* you must implement all queries
* semantics may leak across implementations (IDs are integers
  w/memory implementation but are UUIDs in another)
* time required to implement "real" persistence after all domain
  classes & relationships are known
* hard to grasp conceptually after working with more simple patterns
* every implementation is application specific ; no consistency
  similar to using ActiveRecord in multiple projects

Deciding to use a repository is a big decision. It will have serious
impacts on how you develop and think about the whole system. Just like
all tools, it is paramount to choose the right one for the job. I hope
this post helps you decide.

The next post focuses on the public API and what it's like to interact
with these objects.
