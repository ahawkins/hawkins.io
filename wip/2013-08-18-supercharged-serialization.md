---
title: Supercharged Serialization
layout: post
---

I've been working on building an API for an Ember frontend. We're
using `ActiveModel::Serializer` on the backend. This article is about
how I dropped a blower on the backend and turned up the boost. That's
a shoutout to all my fellow gear heads. My current work is not Rails.
It's a more sane setup. The techniques I describe can be ported to
Rails applications. Here's a quick overview of my setup:

* Sinatra serving requests
* Repository pattern for data access
* Different adapters for development/test/production
* Sequel talking to postgres for production

This setup works very well for our domain logic. I really enjoy
because we have complex data access rules. It also ensures that every
data request goes through a known set of method calls on the
repository. This makes caching extremely easy. It also allows me to
request objects specifically crafted for a given use case. JS
applications are very read heavy. They need **all** the data to do
anything. Having the proper structure on the backend makes optimizing
for specific use cases trivial. I've created two different data flows
inside the backend. There is the read layer: clients hammer away with
GET requests and go through heavily optimized code paths for a
specific requirement set. That being said, let's get onto the meat of
it.

All data objects implement two caching protocols. They all respond to
`#cache_key`. Any layer can cache the object as they see it. Since
access goes through the repository, it's very easy to keep every data
object in memcache. This avoids a call to postgres on every basic
object look (read PK selection). This is by far the most common case
in our application. Secondly, every object implements `#mashal_load`
and `#marhsal_dump`. This ensures every object can be stored in the
cache without any problems. How many times have you tried to put an
ActiveRecord instance into memcache? Gonna have a bad time there. I've
specifically designed our code to avoid these problems. The repository
pattern is the most important bit. It makes all this possible by seperating
persistance from data. We can cache individual objects or complex 
object graphs without worrying. This covers the data access layer. It
provides objects to a higher layer in the system. Now onto
serialization.

The `GET /collection` is the single most important API call for single
page applications. Its only job is to provide data as fast as
possible. I'm talking 100ms are bust regardless of how many objects
need to be serialized. I can safely say we are well under that
threshold for serializing thousands of objects. We'd never actually do
this because of bandwidth concernss, but right we can serialize records
pretty damn fast.

The first step is optimizing your caching. Cache reads are not free.
They should happen very quickly but you must deal with network
latency. You should always use `read_multi`. All
`ActiveSupport::Cache` support this call. We use this when
materializing data objects from queries. I mentioned previously that
all individiual data objects are kept in memcache. A query may have
some of it's objects already loaded. When a query result is
materialized, it reads all the values from the cache and only
materializes what's needed. This is extremely important in our case
because materialization can require more queries to fully populate the
domain objects. We also used this technique inside
ActiveModel::Serializers. We don't need this anymore, but I'll share
the implementation with you.

```ruby
class FastArraySerializer < ActiveModel::ArraySerializer
  cached true

  def serializable_array
    serializers = @object.map do |item|
      item.active_model_serializer.new item, @options
    end

    cache_map = serializers.reduce({}) do |map, serializer|
      map.merge expand_cache_key(serializer.class.name.underscore, serializer.cache_key, 'serializable-hash') => serializer
    end

    results = cache.read_multi *cache_map.keys

    cache_map.map do |pair|
      key, serializer = *pair

      if results.key? key
        results.fetch key
      else
        serializer.serializable_hash
      end
    end
  end
end
```

You can use the `FastArraySerializer` in place of the standard
`ActiveModel::ArraySerializer`. I recommend you do some benchmarking
to figure out its best use case. If your object load time is faster
than a cache request then it doesn't make any sense to this. I saw
significant gains in part of our application. Give it a go and see how
it works for you.

Now comes my favorite thing I've done in a long time. We tried to use
sideloading in our application. This caused two problem:

* We couldn't dump the object graph fast enough
* It broke Ember Data. We would update one record, then the server
  would dump it's graph which sometimes contained an inflight record.
  This causes an error and wasn't worth the trouble.

We decided it wasn't worth the effort to continue with it. If we could
solve #1, we'd still be bit by #2. It made more sense for to simply
ignore dumping full objects and focus on optimizing ID retrevial. This
is easier for a few reasons.

* Disabling `include: true` allows to focus on a specific subset of
  data. This makes optimizing and caching must easier. Caching an
  object graph in your application may be impossible due to object
  associations. The more associations the more problems. This way we
  know exactly what data is needed to serialize one object.
* Smaller responses means faster travel over the network. It's easier
  to make many requests when they are returning sub 100ms.
* Clients can uses the `?id=[]` query parameter to query a subset if
  needed. These can be fast by the same logic.

The data in your JSON unfortunately usually mirrors some sort of DB
stucture. You provide the "raw" data, essentially ID's and column
values. There is absoutely no point to load anything more.
Unfortunately, AMS does not seem to care about this as much as I'd
like. It is somewhat noob. It will simply do a `map(&:id)` over
collections. This is a naive approach. You can implement methods on
the serializer if you have a fast way to provide ids. This this is not
the right way to do things. Instead ask the collection to give you
its ids. The collection object itself always knows the fastest way to
retrevie the ID's of its members. It's incorrect to assume it should
be map operation. I suggest you patch AMS to call `#ids` when
serializing `has_many` associations. You can easily patch AR's queries
to have an `ids` method by using `pluck`. This will speed up your
serialization process dramatically. Otherwise it will fully load all
the objects to simply get the ID. I combined this with custom lazy
loading of all internal associations. This made a huge difference but
it did not solve the problem completely. We still we were going too
many queries. Say each object needs 5 association ids. Now you have
100 objects. That's 500 queries. Network access isn't free and each
query costs something.

It was time for a radical solution: SQL views + Postgres 9.2's new
JSON features. Its possible to create a view that contains all the
data needed to serialize one objects graph. So in order to serialize
one record, it's a simple "primary key" lookup. The SQL can get pretty
hairy, but it has worked like a charm. An objects associations are
captured as a JSON array of ids. Objects embedded are also stored in
JSON columns.

Here's a real life example.

```ruby
create_view :meeting_graphs, <<-sql
  SELECT
    meetings.id,
    meetings.topic,
    meetings.location,
    meetings.starts_at,
    meetings.ends_at,
    meetings.cancelled,
    meetings.personal,
    meetings.created_at,
    meetings.updated_at,
    meetings.organizer_id,
    meetings.reference_email_id,
    meetings.reference_deal_id,
    meetings.account_id,

    ts.ids AS todo_ids,
    cs.ids AS call_ids,

    invs.invitations,

    c.comments AS comments
  FROM meetings

  LEFT JOIN (
    SELECT
      reference_meeting_id AS meeting_id,
      array_to_json(array_agg(id)) AS ids
    FROM todos
    GROUP BY meeting_id
  ) AS ts ON ts.meeting_id = meetings.id

  LEFT JOIN (
    SELECT
      reference_meeting_id AS meeting_id,
      array_to_json(array_agg(id)) AS ids
    FROM calls
    GROUP BY meeting_id
  ) AS cs ON cs.meeting_id = meetings.id

  LEFT JOIN (
    SELECT
      meeting_id,
      (array_to_json(array_agg((SELECT row_to_json(r)
          FROM (values(comments.id, comments.text, comments.author_id, comments.created_at, comments.updated_at))
           r(id, text, author_id, created_at, updated_at)))
      )) AS comments
    FROM comments
    WHERE meeting_id IS NOT NULL
    GROUP BY meeting_id
  ) AS c ON c.meeting_id = meetings.id

  LEFT JOIN (
    SELECT
      meeting_id,
      (array_to_json(array_agg((SELECT row_to_json(r)
          FROM (values(invitations.id, invitations.status, invitations.person_contact_id, invitations.person_user_id, invitations.meeting_id))
           r(id, status, person_contact_id, person_user_id, meeting_id)))
      )) AS invitations
    FROM invitations
    WHERE invitations.organizer = false
    GROUP BY meeting_id
  ) AS invs ON invs.meeting_id = meetings.id
  sql
```

The first two joins compute the required id array. The second two
compute all data needed for embedded associations. Then I can simply
say `MeetinGraph.find(1)` and I have all the data needed to serialize
that given meeting. I've also changed some of our complex data access
logic to use an SQL view as well. When a user does `GET /collection`
that may join the accessible join table with the serialization table.
Boom. All the records provided in milliseconds.

Here are some benchmarks of my various implemenations:

```
                 user     system      total        real
Uncached     1.640000   0.120000   1.760000 (  2.477953)
Cached       0.800000   0.060000   0.860000 (  1.147160)
View Load    0.010000   0.000000   0.010000 (  0.076890)
```
