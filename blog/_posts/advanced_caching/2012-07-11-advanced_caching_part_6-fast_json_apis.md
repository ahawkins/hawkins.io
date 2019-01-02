---
layout: redirect
title: "Advanced Caching: Part 6 - Fast JSON APIs"
tags: [rails, tutorials]
hide: true
redirect: "https://railscaching.com/guide/part-6-fast-json-apis/"
---

All I care about is fast JSON API's. That's all I work on and that's
what I devote all my energy to. We can use all the principles here to
create a simple example of a fast API.

## Structuring a JSON API

This example assumes a few things:

* ActiveRecord backed objects
* Server is essentially a dumb store (no logic in controllers)
* ActiveModel::Serializers for JSON generation
* HTTP caching in the controllers
* Fragment caching for JSON

## Classes

```ruby
# monkey patch ActiveRecord to add methods for caching
# same code from earlier

module ActiveRecord
  class Base
    def self.cache_key
      Digest::MD5.hexdigest "#{scoped.maximum(:updated_at).try(:to_i)}-#{scoped.count}"
    end
  end
end
```

```ruby
# Only GET method are implemented in this example

class ResourceController < ApplicationController
  responds_to :json

  def index
    # uses our cache_key method defined on ActiveRecord::Base to
    # set the etag
    if stale? collection do
      # Use cached JSON from individual hashes to render a collection
      respond_with collection
    end
  end

  def show
    # uses resource.updated_at to set the Last-Modified header
    # uses resource.cache_key to set the ETag
    if stale? resource do
      # Use cached JSON if possible
      respond_with resource
    end
  end
end
```

```ruby
# Uses russian doll technique
class ApplicationSerializer < ActiveModel::Serializer
  delegate :cache_key, :to => :object

  # Cache entire JSON string
  def to_json(*args)
    Rails.cache.fetch expand_cache_key(self.class.to_s.underscore, cache_key, 'to-json') do
      super
    end
  end

  # Cache individual Hash objects before serialization
  # This also makes them available to associated serializers
  def serializable_hash
    Rails.cache.fetch expand_cache_key(self.class.to_s.underscore, cache_key, 'serilizable-hash') do
      super
    end
  end

  private
  def expand_cache_key(*args)
    ActiveSupport::Cache.expand_cache_key args
  end
end
```

## Background Cache Warming

We've consolidated all the JSON generation into individual classes.
Since the API only returns JSON we can generate that JSON silently in
the background to warm the caches. This won't do anything about HTTP
caching but it will make initial requests faster since JSON will be
cached. Here's a simple Sidekiq worker:

```ruby
class CacheWarmer
  include Sidekiq::Worker

  def perform
    Post.find_each do |post|
      serializer = post.active_model_serializer.new post
      # This wil cache the JSON and the hash it's generated from
      serializer.to_json
    end
  end
end
```

And that's all there is too it folks! It's not complicated but it will
make your API significantly faster.

## Index

1. [Caching Strategies](/2012/07/advanced_caching_part_1-caching_strategies)
2. [Using Strategies Effectively](/2012/07/advanced_caching_part_2-using_strategies)
3. [Handling Static Assets](/2012/07/advanced_caching_part_3-static_assets)
4. [Stepping Outside the HTTP Request](/2012/07/advanced_caching_part_4-stepping_outside_the_http_request)
5. [Tag Based Caching](/2012/07/advanced_caching_part_5-tag_based_caching)
6. [Fast JSON APIs](/2012/07/advanced_caching_part_6-fast_json_apis)
7. [Tips and Tricks](/2012/07/advanced_caching_part_7-tips_and_tricks)
8. [Conclusion](/2012/07/advanced_caching_part_8-conclusion)
