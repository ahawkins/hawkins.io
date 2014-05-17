---
title: Supercharged Serialization
layout: post
---

I've built an API for an Ember (+Ember-Data) frontend. We're
using `ActiveModel::Serializer` on the backend. This article is about
how I dropped a blower on the backend and turned up the boost. This
post chronicles the optimizations and architecture bits that make it
all fit together.

All entities implement two caching protocols. They all respond to
`#cache_key`. Any layer can cache the object as they see it. Secondly,
every entity implements `#mashal_load` and `#marhsal_dump`. This
ensures the object behaves correctly when stored in memcached.  We can
cache individual objects or complex object graphs without worrying.

The `GET /collection` is the most important API call for JS
applications. Its only job is to provide data as fast as
possible. I'm talking 100ms or bust regardless of how many results.

First optimize the caching. Cache reads are not free. Excessive reads
can be cost ineffective because network latency. You should also
precompute what your requests and use `read_multi`. `read_multi` reads
N items in a single request. This is a major win when operating on
lists. `ActiveSupport::Cache` support this call. We use this when
materializing data objects from queries. I mentioned previously that
all individiual data objects are kept in memcache. A query may have
some of it's objects already loaded. When a query result is
materialized, it reads all the values from the cache and only
materializes what's needed. This is vital in our case because
materialization may require more queries to fully populate the domain
entities. We also used this technique inside ActiveModel::Serializers.
We don't need this anymore, but I'll share the implementation with
you.

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
than a cache request then it doesn't make any sense. I saw
significant gains in parts of our application. Give it a go and see how
it works for you.

Now comes my favorite thing I've done in a long time. We tried to use
sideloading in our application. This caused two problem:

* We couldn't dump the object graph fast enough
* It broke Ember Data. We would update one record, then the server
  would dump its graph which sometimes contained an inflight record.
  This causes an error and wasn't worth the trouble.

We decided it wasn't worth the effort to continue with it. If we could
solve #1, we'd still be bit by #2. It was more sensible to ignore
dumping full objects and focus on optimizing ID retrevial. This is
easier for a few reasons.

* Disabling `include: true` allows to focus on a specific subset of
  data. This makes optimizing and caching must easier. Caching an
  object graph may be impossible due to object
  associations. The more associations the more problems. This way we
  know exactly what data is needed to serialize one object.
* Smaller responses means faster travel over the network. It's easier
  to make many requests when they are returning sub 100ms.
* Clients can uses the `?id=[]` query parameter to query a subset if
  needed. These can be fast by the same logic.

JSON usually mirrors some sort of DB stucture. You provide the "raw"
data, essentially ID's and column values. There is absoutely no point
to load anything more. Unfortunately, AMS does not seem to care about
this as much as I'd like. It will simply do a `map(&:id)` over
collections. This this is not the right way to do things. Instead ask
the collection to give you its ids. The collection knows the fastest
way to retrevie the ID's of its members.  I suggest you patch AMS to
call `#ids` when serializing `has_many` associations. You can easily
patch AR's queries to have an `ids` method by using `pluck`.  This
speeds the serialization process dramatically. Otherwise it will fully
load all the objects to simply get the ID. I combined this with custom
lazy loading of all internal associations. This made a huge difference
but it did not completely solve the problem. We we were still doing
too many queries. Say each object needs 5 association ids. Now you
have 100 objects. That's 500 queries. Network access isn't free and
each query costs something.

It was time for a radical solution: SQL views + Postgres 9.2's new
JSON features. It is possible to create a view that contains all the
JSON for one object graph. This is an excellent solution because you
do not need to concern yourself with caching. The database will update
the view anytime the associated data changes. This is a godsend when
you have complex associations. This changes serialization from a
series of queries to a single primary key lookup in the view table.
The SQL can get pretty hairy, but it has worked like a charm. An
objects associations are captured as a JSON array of ids. Embedded
objects are also stored in JSON columns.

NOTE: The backend uses a repository and the Sequel gem to talk to
PostgreSQL.

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

The first two joins compute required ID arrays. The second two
compute all data needed for embedded associations. That results in a
row that be directly dumped in the response. Secondly, since it's a
standard table you can do joins and other queries against it. We use
this to query accessible records. The final result is pretty darn
fast.

Here are some benchmarks of my various implemenations `Uncached` is
without optimizations. `cached` is using `multi_get` and the
`FastArraySerializer` technique mentioned. `View Load` is self
explanatory. The benchmarks cover a set of 1000 objects.

```
                 user     system      total        real
Uncached     1.640000   0.120000   1.760000 (  2.477953)
Cached       0.800000   0.060000   0.860000 (  1.147160)
View Load    0.010000   0.000000   0.010000 (  0.076890)
```
