---
layout: redirect
title: "Advanced Caching: Part 4 - Moving Away from the HTTP Request"
tags: [rails, tutorials]
hide: true
redirect: "https://railscaching.com/guide/part-4-stepping-outside-the-http-request/"
---

Everything we've done so far has been in the HTTP request context.
Complex applications live outside HTTP. They have background processes
that interact with external systems and update data. This is a problem
when using standard Rails caching. This section is about handling those
problems.

## Setting the Stage

We know that action caching is dependent on URLs.
Fragment caching is dependent on the view being rendered. However, we
know that both of these methods use `Rails.cache` under the covers to
store content. We can use `Rails.cache` any where in our code. Unlike
`caches_path`, `caches_action` and `cache` that don't hit the cache
if `perform_caching` is set to false, the `Rails.cache` methods will
**always** touch the cache. Ideally, it would be nice to
create a simple observer for our models. If would be cool if we had a
class like this:

```ruby
class Cache
  def self.expire_page(*args)
    # do stuff
  end

  def self.expire_action(*args)
    # do stuff
  end

  def self.expire_fragment(*args)
    # do stuff
  end
end
```

Then we can use this utility class anywhere in our code to expire
different things we have cached. First, we need to be able to generate
URLs from something other than a controller. You may be familiar with
this problem. Mailers are not controllers, but you can still generate
URLs. You need a host name to generate URLs. The controller has this
information because they accept HTTP requests which contain that
information. Mailers do not. That's why the host name must be configured
in the different environments. We can create a frankenstein class that
takes parts of ActionMailer to generate URLS. Once we can generate URLs
we can expire pages and actions. URL helpers are in this module
`Rails.application.routes.url_helpers`. We also need a class level
variable for the host name. Here's what we can do so far:

```ruby
class Cache
  include Rails.application.routes.url_helpers # for url generation

  def self.default_url_options
    ActionMailer::Base.default_url_options
  end

  def expire_action(*args)
    # do stuff
  end

  def expire_fragment(*args)
    # do stuff
  end
end
```

Now we can pull in some knowledge on how the cache system works to fill
in the gaps. Some of this comes from reading the various source files
and observation in generating the cache keys. Here is the complete
class:

```ruby
class Cache
  include Rails.application.routes.url_helpers # for url generation

  def self.default_url_options
    ActionMailer::Base.default_url_options
  end

  def expire_action(key, options = {})
    expire(key, options)
  end

  def expire_fragment(key, options={})
    expire(key, options)
  end

  private
  def caching_enabled?
    return ActionController::Base.perform_caching
  end

  def expire(key, options = {})
    return unless caching_enabled?
    Rails.cache.delete expand_cache_key(key), options
  end

  def expand_cache_key(key)
    # if the key is a hash, then use url for
    # else use expand_cache_key like fragment caching
    to_expand = key.is_a?(Hash) ? url_for(key).split('://').last : key
    ActiveSupport::Cache.expand_cache_key to_expand, :views
  end
end
```

Since action and fragment caching all use Rails.cache under the hood, we
can simply generate the keys ourselves and remove them manually--all
without the fuss of HTTP Requests. Now you can create an initializer to
define a method on your application namespace so it's globally
accessible. I like this way because it's easy to reference in any piece
of code.

```ruby
# config/initializers/cache.rb
require 'cache'

module App # whatever you application module is
  class << self
    def cache
      @cache ||= Cache.new
    end
  end
end
```

Now we can merrily go about our business expiring cached content from
**anywhere.** Here are some examples:

```ruby
App.cache # reference to a Cache instance

App.cache.expire_fragment @post
App.cache.expire_fragment [@post, 'sidebar']
App.cache.expire_fragment 'explicit-key'

# in a controller
App.cache.expire_fragment post_url(@post)
# Have to pass in the hash since it's most likely
# that you won't have access to the url helpers
# in whatever scope your're in.
App.cache.expire_action :action => :show, :controller => :posts, :id => @post, :tag => @post.updated_at.to_i
```

The `expire_fragment` and `expire_action` methods work just like the
ones described in the Rails guides. Only difference is, you can use them
anywhere. Now we can easily call this code in an observer. The observer
events will fire every time they happen **anywhere in the codebase.**
Here's an example. I am assuming a todo is created outside an HTTP
request through a background process. The observer will capture the
event.

```ruby
class TodoObserver < ActivRecord::Observer
  def after_create
    App.cache.expire_fragment :controller => :todos, :action => :index
  end
end
```

The beauty here is that we can use this code anywhere. If you have more
complicated cache expirations you may have to use a background job. This
may not be acceptable because of processing time, but in some situations
you can afford a sweeping delay if the sweeping process takes a long
time. You could easily use this code with Sidekiq or Resque if
needed. After all, the generated rails code does reference a cache
observer--now you know how to write one.

## Index

1. [Caching Strategies](/2012/07/advanced_caching_part_1-caching_strategies)
2. [Using Strategies Effectively](/2012/07/advanced_caching_part_2-using_strategies)
3. [Handling Static Assets](/2012/07/advanced_caching_part_3-static_assets)
4. [Stepping Outside the HTTP Request](/2012/07/advanced_caching_part_4-stepping_outside_the_http_request)
5. [Tag Based Caching](/2012/07/advanced_caching_part_5-tag_based_caching)
6. [Fast JSON APIs](/2012/07/advanced_caching_part_6-fast_json_apis)
7. [Tips and Tricks](/2012/07/advanced_caching_part_7-tips_and_tricks)
8. [Conclusion](/2012/07/advanced_caching_part_8-conclusion)
