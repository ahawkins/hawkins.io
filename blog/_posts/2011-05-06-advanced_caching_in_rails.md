---
layout: post
title: Advanced Caching in Rails
tags: [rails, tutorials]
---

<~~ 
  COOL This stuff is orange!
  Things to cover:
  * HTTP Caching
  * Page Caching
  * Caching helper module from Radium
  * RAILS_APP_VERSION: A fresh cache on every deploy
  * Caching in the asset pipeline
  * Caching, rails, and static assets
  * Cache log subscriber
~~>

**NOTE**: This post is very popular and has been referenced many times.
This post was originally for Rails 2.3. It has been updated for Rails 3.

Caching in Rails is covered occasionally. It is covered in very basic
detail in the caching [guide](http://guides.rubyonrails.org/caching_with_rails.html).
Advanced caching is left to reader. Here's where I come in. I recently
read part of Ryan Bigg's [Rails 3 in Action](http://www.manning.com/katz/) upcoming 
Rails book (review in the works) where he covers caching. He does a
wonderful job of giving the reader the basic sense of how you can use
page, action, and fragment caching. The examples only work well in a
simple application like he's developing in the book. I'm going to show
you how you can level up your caching with some new approaches.


## Moving Away from the HTTP Request

Now we're going to write some code to address problems in the Rails
caching system. We know that action caching is dependent on URLS.
Fragment caching is dependent on the view being rendered. However, we
know that both of these methods use `Rails.cache` under the covers to
store content. We can use `Rails.cache` any where in our code. Unlike
`caches_path`, `caches_action` and `cache` that don't hit the cache
if `perform_caching` is set to false, the `Rails.cache` methods will
**always** touch the cache. Ideally, it would be nice to
create a simple observer for our models. What it would be cool if we had
a class like this:

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

Then we can use that utility class anywhere in our code to expire
different things we have cached. First, we need to be able to generate
URL's from something other than a controller. You may be familiar with
this problem. Mailers are not controllers, but you can still generate
URL's. You need a host name to generate paths. The controller have this
information because they accept HTTP requests which have that
information. Mailers do not. That's why the host name must be configured
in the different environments. We can create a frankenstein class that
takes parts of ActionMailer to generate URLS. Once we can generate URL's
we can expire pages and actions. URL generation is included this module
`Rails.application.routes.url_helpers`. That's a shortcut method for the
generated module which contains `url_for`, `path_for` and all the named
route helpers. We also need a class level variable for the host name.
Here's what we can do so far:

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
# FIXME: Update for Rails 3!
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

    def expire_fragment(*args)
      cache.expire_fragment(*args)
    end

    def expire_action(*args)
      cache.expire_fragment(*args)
    end
  end
end
```

Now we can merrily go about our business expiring cached content from
**anywhere.** Here are some examples:

```ruby
App.cache # reference to a Cache instance

App.expire_fragment @post
App.expire_fragment [@post, 'sidebar']
App.expire_fragment 'explicit-key'

# in a controller
App.expire_fragment post_url(@post)
# Have to pass in the hash since it's most likely
# that you won't have access to the url helpers
# in whatever scope your're in.
App.expire_action :action => :show, :controller => :posts, :id => @post, :tag => @post.updated_at.to_i
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
    App.expire_fragment :controller => :todos, :action => :index
  end
end
```

The beauty here is that we can use this code anywhere. If you have more
complicated cache expirations you may have to use a background job. This
may not be acceptable because of processing time, but in some situations
you can afford a sweeping delay if the sweeping process takes a long
time. You could easily use this code with DelayedJob or Resque if
needed. After all, the generated rails code does reference a cache
observer--now you know how to write one.

## Tag Based Caching

This is an approach I came up with to work in this situation:

1. Maintain control over how long things are cached
2. Large number of different associations. Actions or fragments no
   longer related to a specific resource. 
3. Content could be invalidated through HTTP requests or any number of
   background process.
4. Hard to maintain specific keys. I thought of it as "resources".

There is a ton of cached content in the system. Many different actions
and fragments. There was also a cache hierarchy. Expiring a specific
fragment would have to expire an action (so a cache miss would occur
when a page was requested thus, causing the new fragment to be
displayed) while other things on pages are still cached. One question to
ask, is how can I expire groups of things based on certain events? Well,
first you need a way to associate different keys. Once you can associate
different keys, then you can expire them together. Since you're tracking
the keys being sent to `Rails.cache`, you can simply use `Rails.cache`
to delete them. All of this is possible through one itty-bitty detail of
the Rails caching system. 

You may have noticed something in the `Cache` class in the previous
section. There is a second argument for `options`. Anything in the
`option` argument is passed to the cache store. This is where can tie in
the grouping logic. Also, since action and fragment caching use the same
mechanism to write to the cache, we simply have to override the
`write_fragment` method to add our tagging logic.

Through all of this trickery, you'll be able to express this type of
statement:

```ruby
App.cache.expire_tag 'stats' 
App.cache.expire_tag @account
```

The content could from anywhere, but all you know is that's stale.

This is exactly where [Cashier](http://rubygems.org/gems/cashier) comes
in. It (is my gem) that allows you associate actions and fragments with
one or more tags, then expire based of tags. Of course you can expire
the cache from anywhere in your code. Here are some examples:

    caches_action :stats, :tag => proc {|c|
      "account-#{Account.find(c.params[:id]).id}"
    }

    caches_action :show, :tag => 'account'
    caches_cation :show, :tag => %w(account customer)

    <%= cache @post, :tag => 'customer' do %>

Then you can expire like this:

```ruby
Cashier.expire 'account' # wipe all keys tagged 'account'
```

All this is possible through this module:

```ruby
module Cashier
  module ControllerHelper
    def self.included(klass)
      klass.class_eval do
        def write_fragment_with_tagged_key(key, content, options = nil)
          if options && options[:tag] && Cashier.perform_caching? 
            tags = case options[:tag].class.to_s
                   when 'Proc', 'Lambda'
                     options[:tag].call(self)
                   else 
                     options[:tag]
                   end
            Cashier.store_fragment fragment_cache_key(key), *tags
          end
          write_fragment_without_tagged_key(key, content, options)
        end
        alias_method_chain :write_fragment, :tagged_key
      end
    end
  end
end
```

I higly recommend you checkout [Cashier](http://rubygems.org/gems/cashier).
It may be useful in your application especially if you have complicated
relationships with high performance requirements.

## Caching Complicated Actions (or Methods)

Let's say you have an index action. However, it's more complicated than
a normal scaffold index. The user can search, filer, sort and apply
different query options. Think for example a form build with MetaWhere
or Sunspot. There are infinite number of combinations, but the data is
always the same. That is, a search for "EC2" will always have the same
results as another search for "EC2" as long as the underlying data
hasn't changed. We could easily cache the index action if we could
figured how to represent each unique combination of input parameters as
a key value. Memcached also has a key length limit. I don't know what it
is off the top of my head, but you should try to keep the key short.
How can we do this? We use a **cryptographic hash.** A cryptographic
hash is guaranteed to be unique given a unique set of input parameters.
This means there no collisions.

    hash(key1) != hash(key2) # will always be true

The Ruby Standard Library comes with MD5. MD5 is good hashing function
so we'll have no problems using it for these examples. MD5 is faster
than SHA1. SHA1 provides better keys but it's nothing to worry about for
this use case. It takes a string
input and generates a hash. We'll create a composite key with a
timestamp and string representation of the input parameters.

```ruby
require 'digest/md5'

class ComplicatedSearchController < ApplicationController

  caches_action :search, :cache_path => proc {|c|
    timestamp = Model.maximum(:updated_at)
    string = timestamp + c.params.inspect
    { :tag => Digest::MD5.hexdigest(string) }
  }
end
```

That will cache every combination of input parameters you can throw at
it. This is perfect for actions with pagination as well. It's perfect
for anything that uses the same underlying data based on input
parameters. This can save your bacon if a search takes a few seconds. If
one user just did the same search, the second user won't have to wait at
all. Hell, they might even be impressed.

## Bringing Caching into the Model Layer

Caching isn't just for views. Some DB operations or methods make be
computationally intensive. We can use `Rails.cache` inside the models to
make them more efficient. Let's say you wanted to cached the listing of
all the top 100 posts on reddit.

```ruby
class Post
  def self.top_100
    timestamp = Post.maximum(:updated_at)
    Rails.cache.fetch ['top-100', timestamp.to_i'].join('/') do
      order('vote_count DESC').limit(100).all
    end
  end
end
```

I've used `maximum(:updated_at)` a few times.  
We can use these concepts to do more fun stuff. My main project
has companies and customers. An account has many customers and
companies. It's typical that I need to retrieve all the customers per an
account. This can be 10000 records. That takes time. ActiveRecord
instantiation on that order is not free. However, I only care about
customers or companies in the scope of a specific account. That means, I
only use the account and customers/companies association. Rails gives
you the ability to specific a different attribute for `:touch` on
`belongs_to`. I use this to my advantage to create an
`association_name_updated_at` column. Then specify `:touch =>
association_name_updated_at`. Here's how it looks in code:

```ruby
class Account < ActiveRecord::Base
  has_many :customers
end

class Customers < ActiveRecord::Base
  belongs_to :account, :touch => :customers_updated_at
end
```

That gives me a timestamp I can use to generate all keys. Now I can use
`Rails.cache` to fetch different queries and keep them all cached. You can
wrap this functionality in a module and include in other associations.

```ruby
require 'digest/md5'

module CachedFinderExtension
  def cached(options = {})
    key = Digest::MD5.hexdigest options.to_s
    association_name = proxy_reflection.name
    owner_key = [proxy_owner.class.to_s.underscore, proxy_owner.id].join('/')
    tag = proxy_owner.send("#{association_name}_updated_at").to_i

    Rails.cache.fetch [owner_key, association_name, tag, key].join('/') do
      all options
    end
  end
end
```

`all` is a method that takes many options. We don't really care what's
passed in, we just need to be able to generate a cache key based on the
input parameters. Since we know when the association was last updated,
the method will return fresh content depending if records have been
modified. Include the extension in your association and you're on your
way!

```ruby
class Account < ActiveRecord::Base
  has_many :customers, :extend => CachedFinderExentsion
end

# all find's now automatically cached and expired
@account.customers.cached(:conditions => {:name => 'Adam'})
@account.customers.cached(:order => 'name ASC', :limit => 10})
```

These are just examples of what you can do with caching in the model
layer. You could even write the type of cached finder extension for
ActiveRecord::Base. This is different from SQL caching since it only
persists through request--this is cached throughout the entire
application.

**Note about this code**: The ActiveRecord query API has changed
significantly in Rails 3. Thise method does not look at clean as it
could go be. It does not allow you write things like:
`account.customers.cached.where(conditions).order(columns)`. It can
however by using a proxy. This functionality is left as an example to
the reader.


## CSRF and form\_authenticty\_token

Rails uses a CSRF
(Cross Site Request Forgery) token and a form authentic token to
protect your application against attacks. These are generated per
request and each pages get unique values each time.
`protect_from_forgery` is added by default to `ApplicationController`.
You may have run into the problem before. You may have tried to submit
a POST and received an Unauthorized response. This is the
`form_authenticity_token` in action. You can fiddle with it and see what
happens to your application.

These tokens cause problems (depending on what Rails version) you're
using with cached HTML. Caching a page or an action with a form may
generate unauthorized errors because the tokens were for a different
session or request. There are parts of the cached pages that need to be
_replaced_ with new values before the application can be used. This is a
simple process, but it will take another HTTP request. 

<~~ FIXME: Add example of security issue with fix! ~~>

## Dealing with Relative Dates (or other content)

Many Rails applications use `distance_of_times_in_words` throughout
their application. This can cause major problems for any cached content
with a data. For example, you have a fragment cached. That fragment was
cached 1 month ago. 2 months ago, it's still in the cache. Since you
stored a relative date in the cache, the fragment contains '1 month
ago'. This is no good. You can solve this problem easily with
JavaScript.

JavaScript is better for handling dates/times than Rails is. This is
because Rails needs to know what the user's time zone is, then marshal
all times into that time zone. JavaScript is better because it use the
local time zone by default. How often do you want to display a time in a
different zone than user's current locale? You can dump the UTC
representation of the date into the DOM, then use JS to parse them into
relative or something like `strftime`. I've encapsulated this process in
a helper in my Rails applications. Once all the data is in the DOM, you
can do all the parsing in JavaScript.

```ruby
def timestamp(time, options = {})
  classes = %w(timestamp)
  classes << 'past' if time.past?
  classes << 'future' if time.future?

  options[:class] ||= ""
  options[:class] += classes.join(' ')

  content_tag(:span, time.utc.iso8601, options)
end
```

Then, when the page loads you can use a library like date.js to create
more user friendly dates.

## Time to Cash Out

I've covered a ton of material in this article. I've given a through
explanation of how all the Rails cache layers fit together and how to
use the lowest level to it's full potential. I've provided a solution
for managin the cache outside the HTTP request cycle as well as shown
you how to bring caching into the model layer. This is not the
be-all-and-all of caching in Rails. It is a indepth look at caching in a
Rails application. I'll leave you with a quick summary of everything
covered and some few goodies.

### Page Caching

1. The simplest and easiest thing that could possibly work.
2. Usually not applicable to any web application. Have a form? No good,
   the `form_authenticity_token` will be no good and Rails will reject
   it.

### Action Caching

1. Most bang for the buck. Can usually be applied in many different
   circumstances.
2. Uses fragment caching under the covers.
3. Generates a cache key based off the current url and whatever other
   options are passed in
4. Get more mileage by caching actions with an composite timestamped
   key.

### Fragment Caching

1. Good for caching reusable bits of HTML. Think shared partials or
   forms.
2. Use a good cache key for each cache block.
3. Don't go overboard. Requests to memcached are not free. Maximize
   benefits by caching a small number of large fragments instead of a
   large number of small fragments.
4. Use auto expiring cache keys to invalidate the cache automatically.

### General Points

1. Don't worry about sweepers unless you have too.
2. Understand the limitations of Rail's HTTP request cycle 
3. Use cryptographic hashes to generate cache keys when permutations of
   input parameters are invloved.
4. Don't be afraid to use Rails.cache in your models.
6. Tagged based caching is useful in certain situations.
7. Conslidate your cache expritation logic in one place so it's easily
   testable.
8. Test with caching turned on in complex applications.
9. Look into [Varnish](http://www.varnish-cache.org/) for more epic
   wins.
10. belongs to with `:touch => true` is your friend.
11. Use association timestamps
12. Spend time upfront considering your cache strategy.
13. Be weary of examples with expire by regex. This only works on cache
    stores that have the ability to iterate over all keys. **Memcached**
    is not one of those.
