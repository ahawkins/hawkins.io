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
