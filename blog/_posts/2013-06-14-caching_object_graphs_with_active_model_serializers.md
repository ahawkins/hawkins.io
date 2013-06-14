---
layout: post
title: "Caching Object Graphs with ActiveModel::Serializers"
tags: [ember]
---

I've been doing caching consultations for a while. Everyone is using
`ActiveModel::Serializers`. The most common question is: "how can I
speed up my index routes?" The best answer is to cache the generation.
Unfortunately these are usually pretty complex objects graphs which
can make them awkward and complex to cache. `ActiveModel::Serializers`
makes this possible given some leg work. If you make the serializer
response to `cache_key` and set `cached` then the magic will happen.

All we have to do is generate a cache key. We need to know all the
objects to generate a cache key. Given a collection of objects we can
generate a simple cache key by using the maximum `updated_at` value.
Knowing this, we simply have to generate the object collections.
Once we have all that a cache key can be generated.

Let's look at a blog example. We have users, posts, and comments. They
are all related to each other in obvious ways. Here are the
serializers:

```ruby
class UserSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :name, :email, :created_at, :updated_at

  has_many :posts
  has_many :comments
end
```

```ruby
class PostSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :title, :text, :created_at, :updated_at

  has_many :comments
  has_one :user
end
```

```ruby
class CommentSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :text, :created_at, :updated_at

  has_one :post
  has_one :user
end
```

When we hit `GET /blog` we essentially want to dump our entire object
graph to the API consumer. This means we'll dump all the users posts,
and comments into a single JSON response. We can reverse engineer the
collections given the serializer's associations. We have:

* posts => comments
  * then users through comments
* users => posts

So we have need all the comments associated to the posts, all the
users who wrote the comments, and the users who posted the post.
Here's a Ruby class that represent this concept:

```ruby
class PostsGraph
  def initialize(collection)
    @collection = collection
  end

  private
  def post_ids
    @post_ids ||= @collection.pluck :id
  end

  def posters
    @posters ||= User.joins(:posts).where(:posts => { id: post_ids })
  end

  def commentors
    @commentors ||= User.joins(:comments).where(:comments => { :post_id => post_ids })
  end

  def comments
    @comments ||= Comment.joins(:post).where(:post_id => post_ids)
  end
end
```

There is some SQL going on there to get association inverse for a
given collection. The class as methods responding to each set of
objects in the graph. Now we can generate a cache key using the
collections.

```ruby
require 'digest/md5'

class PostsGraph
  def initialize(collection)
    @collection = collection
  end

  def cache_key
    Digest::MD5.hexdigest([
      cachify(@collection),
      cachify(posters),
      cachify(commentors),
      cachify(comments)
    ].join('/'))
  end

  # other methods

  def cachify(scope)
    scope.maximum(:updated_at)
  end
end
```

We simply generate a composite cache key from the set. Now make the
class `ActiveModel::Serializers` ready

```ruby
require 'digest/md5'

class PostsGraph
  include Enumerable

  class CachedArraySerializer < ActiveModel::ArraySerializer
    # set config.action_dispatch.perform_caching = true as well
    cached true

    # call the graph's cache key method
    def cache_key
      object.cache_key
    end
  end

  delegate :each, :to_ary, to: :collection

  def initialize(collection)
    @collection = collection
  end

  def cache_key
    Digest::MD5.hexdigest([
      cachify(collection),
      cachify(posters),
      cachify(commentors),
      cachify(comments)
    ].join('/'))
  end

  # Serializer with our serializer that knows how to
  # cache a graph
  def active_model_serializer
    CachedArraySerializer
  end

  private
  def collection
    @collection
  end

  def post_ids
    @post_ids ||= collection.pluck :id
  end

  def posters
    @posters ||= User.joins(:posts).where(:posts => { id: post_ids })
  end

  def commentors
    @commentors ||= User.joins(:comments).where(:comments => { :post_id => post_ids })
  end

  def comments
    @comments ||= Comment.joins(:post).where(:post_id => post_ids)
  end

  def cachify(scope)
    scope.maximum(:updated_at)
  end
end
```

Now we can simply construct a controller action like usual:

```ruby
def index
  graph = PostsGraph.new Post.scoped

  if stale? etag: graph.cache_key
    render json: graph
  end
end
```

Voilla! Everything is nice and fast. There is one simple problem
though: our cache keys are not exact enough. They must include more
information about their contents. The cache key doesn't take into
account deletions or other query conditions (say published or
unpublished). Here's the final change:

```ruby
def cachify(scope)
  "#{scope.to_sql}-#{scope.count}-#{scope.maximum(:updated_at)}"
end
```

You can apply this technique to larger graphs, just keep in mind there
is a lot of book keeping to do.
