---
layout: post
title: "Advanced Caching in Rails: Part 6 - Fast JSON APIs"
tags: [rails, tutorials]
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
      timestamp = scoped.maximum(:updated_at) || Time.now
      Digest::MD5.hexdigest "#{timestamp.to_i}-#{scoped.count}"
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

And that's all there is too it folks! It's not complicated but it will
make your API significantly faster.
