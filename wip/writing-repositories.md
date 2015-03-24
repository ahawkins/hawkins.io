---
title: "Writing & Using Repositories"
layout: post
---

I've gotten a lot of questions about repositories lately. Not the
github kind. In my joy of design posts I advocate using the repository
pattern to separate data access from persistence. I use the repo found
in [Chassis](http://github.com/ahawkins/chassis) in all my projects.
Naturally I understand everything since I wrote the code.
Unfortunately all of this knowledge is locked up in my head. Hopefully
this post spreads that around. This post describes how I've
implemented repositories across a few different code bases.

The Chassis repo has undergone multiple revisions since my initial
implementation in Radium. It's become more reusable since then. The
implementation uses one facade object that delegates to a class
specific implementation. In human terms, this mean one repository
receives the operations for all persisted classes, but may decide to
persist each class differently. I prefer this approach because my
storage requirements do not vary widly. If they do, this happens in a
different layer in the application where using the repository pattern
does not make sense. The chassis implementation makes it possible to
have class specific repositories if desired, but I've never done such
a thing. I also prefer to centralize access because I can simply say
`repo.clear` in the tests.

Now that bit is out of the way, we can focus on the other aspects.
`Chassis::BaseRepo`
[github](https://github.com/ahawkins/chassis/blob/master/lib/chassis/repo/memory_repo.rb)
is a generic base class that all packaged repositories use. All
operations delegate to the `map`. The `map` object connects a domain
class to a persistence manager. Example: there's a `Post` domain
class. The repo maps `Post` to `PostManager` to handle all `Post`
related persistence logic. `Chassis::Repo::RecordMap`
[github](https://github.com/ahawkins/chassis/blob/master/lib/chassis/repo/record_map.rb)
provides the common interface for CRUD operations. Browse the
prepackaged repositories on
[github](https://github.com/ahawkins/chassis/tree/master/lib/chassis/repo).
You'll see they implement a storage specific map which delegates to
the simple implementation. It's really quite powerful. This struture
works out well for those implementations. The same structure (but not
exact implementation) can be used for more complex stores.

Next, consider how much logic each manager should implement? This is
an interesting question which took me over a year to answer. I
implemented my first repo inside RadiumCRM. The business logic
dictated an extremely high amount of relationships. Naturally I chose
to use an RDMS and implemented a repo using Sequel. I preceded to
create a table with columns for each attribute that would persisting.
Fast forward a couple of months. I had a ton of duplicate and tedious
code to maintain. Given a row in a table, I had manually assign domain
object attributes from column values. This did not scale when some
items had 20 or 30 things. Fast forward to the next major project. I
chose to use a repository implementation. The data had to go MongoDB.
So I naturally sat down and started to write a JSON serializer and
deserializer. This became tedious and also hard to test. There were
virtually no queries (opposed to Radium which had shit loads) so I
only needed to test round tripping complete objects. There was a lot
of ceremony and other problems with this. Then I had a moment of
enlightenment: have the persistence layer use a serialization protocol
from the application layer. This turned out to be a wonderful
decision. It also would've solved the severe code duplication inside
Radium. This also means the same serialized representation can be used
in any data score (long-lived or temporary). The answer to the initial
question is "as little as possible". What other answer is there?

This all happens by redfining the oft untouched methods `marshal_dump`
and `marshal_load`. Then building up a serialization protcol on those
methods. `marshal_load` takes a hash and assigns instance variables.
`marshal_dump` returns a hash that completely reconstruct an instance
with its public and private state. `to_h`, `to_hash`, and `as_json` alias to
`marshal_dump`. That covers the generation part. Now for the reverse.
`from_hash` calls `marshal_load` and returns `self`. Now define a
class method called `from_hash` which instantiates a new object then
calls `from_hash`. You can duplicate this for `from_json`. Voilla, now
you can round trip all the domain objects by using the serialization
protocol defined in `marshal_dump` and `marshal_load`. This is very
powerful since you can unit test serialization/deserialization and no
other object must know all the private internal bits required to
persist the object. Redis calls `to_json`, Mongo calls `as_json`, and
Memcache uses `Marshal.dump` all with the same serialization protocol.
Here's the code.

```ruby
module Persistence
  module ClassMethods
    def from_json(json)
      new.from_json json
    end

    def from_hash(hash)
      new.from_hash hash
    end
  end

  class << self
    def included(base)
      base.include Chassis::Persistence
      base.extend ClassMethods
    end
  end

  def to_h
    marshal_dump
  end
  alias_method :to_hash :to_h
  alias_method :as_json :to_h

  def to_json
    JSON.dump as_json
  end

  def from_json(json)
    from_hash JSON.load(json)
  end

  def from_hash(hash)
    marshal_load hash.symbolize
    self
  end
end
```

Now that we can serialize objects, we must be able to query them based
on arbitary data values. I think this part is cool. My solution is to
store the serialized form and query attribute separately. This has
worked out well so far. This also has an interesting side effect: it's
painfully odbvious what must be indexed. Here's an example in
relational form:

````
| id | user_id | serialized |
| 1  | 2       | ......     |
| 2  | 2       | ......     |
```

If a query requires knowing what `user_id` we can query on that
column. Here's the same idea in JSON form.

```
{
  "query": {
    "user_id": 1
  }
  ...
}
```

Mongo can use things inside the `query` key for same type of logic.
This only works if you know all the queries up front.
