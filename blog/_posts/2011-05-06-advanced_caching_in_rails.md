---
layout: post
title: Advanced Caching in Rails
tags: [rails, tutorials]
---

**Readers Note**: This post has been [revised](/2012/07/advanced_caching_revised/).
I highly suggest you check out that version. This version is outdated
but is left here for historical purposes. I've found some copy related
errors in this post and fixed them in the newer version. Also, this post
is written for **Rails 2**. The revised post focuses on **Rails 3.1+**.

Caching in Rails is covered occasionally. It is covered in very basic
detail in the caching [guide](http://guides.rubyonrails.org/caching_with_rails.html).
Advanced caching is left to reader. Here's where I come in. I recently
read part of Ryan Bigg's [Rails 3 in Action](http://www.manning.com/katz/) upcoming 
Rails book (review in the works) where he covers caching. He does a
wonderful job of giving the reader the basic sense of how you can use
page, action, and fragment caching. The examples only work well in a
simple application like he's developing in the book. I'm going to show
you how you can level up your caching with some new approaches.

## Different Caching Layers

First, let's start with a brief overview of the different types of
caching:

  1. Page Caching: **PRAISE THE GODS** if you actually can use page
     caching in your application. Page caching is the holy grail. Save
     the entire thing. Don't hit the stack & give some prerendered stuff
     back. Great for worthless applications without authentication and
     other highly dynamic aspects.

  2. Action Caching: Essentially the same as page caching, except all
     the before filters are run allowing you to check authentication
     and other stuff that may have prevented the request for rendering.

  3. Fragment Caching: Store parts of views in the cache. Usually for
     caching partials or large bits of HTML that are independent from
     other parts. IE, a list of top stories or something like that. 

  4. Rails.cache: All cached content **except cached pages** are stored
     in the Rails.cache. Cached pages are stored as HTML on disk. We'll
     use the fact that all the cached action and fragment content are
     simply stored in Rails.cache. You can cache arbitrary content in
     the Rails cache. You may cache a large complicated query that you
     don't want to wait to reinstantiate a ton of AR::Base objects.

## Under the Hood

All the caching layers are built on top of the next one. Page caching is
the only exception because it does not use `Rails.cache` it writes
content to disk. The cache is essentially a key-value store. Different
things can be persisted. Strings are most common (for HTML fragments).
More complicated objects can be persisted as well. Let's go through some
examples of manually using the cache to store things. I am using
memcached with dalli for all these examples. Any driver that
implements the cache store pattern should work.

```
# Rails.cache.write takes two value: key and a value
> Rails.cache.write 'foo', 'bar'
=> true

# We can read an object back with read
> Rails.cache.read 'foo'
=> "bar"

# We can store a complicated object as well
> hash = {:this => {:is => 'a hash'}}
> Rails.cache.write 'complicated-object', object
> Rails.cache.read 'complicated-object'
=> {:this=>{:is=>"a hash"}}

# If we want something that doesn't exist, we get nil
> Rails.cache.read 'we-havent-cached-this-yet'
=> nil

# "Fetch" is the most common pattern. You give it a key and a block
# to execute to store if the cache misses. The block is not executed
# if there is a cache hit.
> Rails.cache.fetch 'huge-array' do
    huge_array = Array.new
    1000000.times { |i| huge_array << i }
    huge_array # retrun value is stored in cache
  end
=> [huge array] # took some time to generate
> Rails.cache.read 'huge-array'
=> [huge array] # but returned instantly

# You can also delete everything from the cache
> Rails.cache.clear 
=> [true]
```

Those are the basics of interacting withe the Rails cache. The rails
cache is a wrapper around whatever functionality is provided by the
underlying storage system. Now we are ready to move up a layer.

## Understanding Fragment Caching

Fragment caching is taking rendered HTML fragments and storing them in
the cache. Rails provides a `cache` view helper for this. It's most
basic form takes no arguments besides a block. Whatever is rendered
during the block will be written back to the cache. The basic principle
behind fragment caching is that it takes much less time fetch
pre-rendered HTML from the cache, then it takes to generate a fresh copy.
This is very true. If you haven't noticed, view generation can be very
costly. Let's say you have generated a basic scaffold for a post:

```
$ rails g scaffold post title:string content:text author:string
# that will generate some views to play with
```

Let's start with the most common use case: caching information specific
to one thing. IE: One post. Here is a show view:

```erb
<!-- nothing fancy going on here -->
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>

<p>
  <b>Content:</b>
  <%= @post.content %>
</p>

<p>
  <b>Author:</b>
  <%= @post.author %>
</p>
```

Let's say we wanted to cache fragment. Simple wrap it in `cache` and
Rails will do it.

```erb
<%= cache "post-#{@post.id}" do %>
  <p>
    <b>Title:</b>
    <%= @post.title %>
  </p>

  <p>
    <b>Content:</b>
    <%= @post.content %>
  </p>

  <p>
    <b>Author:</b>
    <%= @post.author %>
  </p>
<% end %>
```

The first argument is the key for this fragment. The rendered HTML is
stored with this key: `views/posts-1`. Wait what? Where did that 'views'
come from? The `cache` view helper automatically prepends 'view' to all
keys. This is important later. When you first load the page you'll see
this in the log:

```
Exist fragment? views/post-2 (1.6ms)
Write fragment views/post-2 (0.9ms)
```

You can see the key and the operations. Rails is checking to see if the
specific key exists. It will fetch it or write it. In this case, it has
not been stored so it is written. When you reload the page, you'll see a
cache hit:

```
Exist fragment? views/post-2 (0.6ms)
Read fragment views/post-2 (0.0ms)
```

There we go. We got HTML from the cache instead of rendering it. Look at
the response times for the two requests:

```
Completed 200 OK in 17ms (Views: 11.6ms | ActiveRecord: 0.1ms)
Completed 200 OK in 16ms (Views: 9.7ms | ActiveRecord: 0.1ms)
```

Very small differences in this case. 2ms different in view generation.
This is a very simple example, but it can make a world of difference in
more complicated situations. 

You are probably asking the question: "What happens when the post
changes?" This is an excellent question! What well if the post changes,
the cached content will **not** be correct. It is up to **us** to remove
stuff from the cache **or** figure out a way to get new content from the
cache. Let's assume that our blog posts now have comments. What happens
when a comment is created? How can handle this?

This is a very simple problem. What if we could figured out a
solution to this problem: How can we create a cache miss when the
associated object changes? We've already demonstrated how we can
explicitly set a cache key. What if we made a key that's dependent on the
time the object was last updated? We can create a key composed of the
record's ID and it's updated_at timestamp! This way the cache key will
change as the content changes **and we will not have to expire things
manually.** (We'll come back to sweepers later). Let's change our cache
key to this:

```erb
<% cache "post-#{@post.id}", @post.updated_at.to_i do %>
```

Now we can see we have a new cache key that's dependent on the objects
timestamps. Check out the rails log:

```
Exist fragment? views/post-2/1304291241 (0.5ms)
Write fragment views/post-2/1304291241 (0.4ms)
```

Cool! Now let's make it so creating a comment updates the post's
timestamp:

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post, :touch => true
end
```

Now all comments will touch the post and change the `updated_at`
time stamp. You can see this in action by `touch`'ing a post.

```
Post.find(1).touch

Exist fragment? views/post-2/1304292445 (0.4ms)
Write fragment views/post-2/1304292445 (0.4ms)
```

This concept is known as: **auto expiring cache keys.** You create a
composite key with the normal key and a time stamp. This will create some
memory build up as objects are updated and no longer create cache hits.
For example. You have that fragment. It is cached. Then someone updates
the post. You now have two versions of the fragment cached. If there are
10 updates, then there are 10 different versions. Luckily for you, this
is not a problem for memcached! Memcached uses a LRU replacement policy.
LRU stands for Least Recently Used. That means the key that hasn't been
request in the longest time will be replaced with new content needs to
be stored. For example, assume your cache can only hold 10 posts. The
next update will create a new key and hence new content. Version 0 will
be deleted and version 11 will be stored in the cache. The total amount
of memory is cycled between things that are requested. There are two
things to consider in this approach. 1: You will not be able to ensure
that content is kept in the cache as long as possible. 2. You will never
have to worry about expiring things manually as long as timestamps are
updated in the model layer. I've found it is orders of magnitude easier
to add a few `:touch => true`'s to my relationships than it is to
maintain sweepers. More on sweepers later. We must continue exploring
cache keys.

Rails uses auto-expiring cache keys by **default.** The problem is they
are not mentioned at all the documentation or in the guides. There is
one very handy method: `ActiveRecord::Base.cache_key`. This will
generate a key like this: `posts/2-20110501232725`. **This is the
exact same thing we did ourselves.** This method is very important
because depending on what type of arguments you pass into the `cache`
method it will be called on them. For the time being, this code is
functionally equal to our previous examples.

```erb
<%= cache @post do %>
```

The `cache` helper takes different forms for arguments. Here are some
examples:

```ruby
cache 'explicit-key'      # views/explicit-key
cache @post               # views/posts/2-1283479827349
cache [@post, 'sidebar']  # views/posts/2-2348719328478/sidebar
cache [@post, @comment]   # views/posts/2-2384193284878/comments/1-2384971487
cache :hash => :of_things # views/localhost:3000/posts/2?hash_of_things
```

If an `Array` is the first arguments, Rails will use cache key expansion
to generate a string key. This means calling doing logic on each object
then joining each result together with a '/'. Essentially, if the object
responds to `cache_key`, it will use that. Else it will do various
things. Here's the source for `expand_cache_key`:

```ruby
def self.expand_cache_key(key, namespace = nil)
  expanded_cache_key = namespace ? "#{namespace}/" : ""

  prefix = ENV["RAILS_CACHE_ID"] || ENV["RAILS_APP_VERSION"]
  if prefix
    expanded_cache_key << "#{prefix}/"
  end

  expanded_cache_key <<
    if key.respond_to?(:cache_key)
      key.cache_key
    elsif key.is_a?(Array)
      if key.size > 1
        key.collect { |element| expand_cache_key(element) }.to_param
      else
        key.first.to_param
      end
    elsif key
      key.to_param
    end.to_s

  expanded_cache_key
end
```

This is where all the magic happens. Our simple fragment caching example
could easily be converted into an idea like this: The post hasn't
changed, so cache the entire result of /posts/1. You can do with this
action caching or page caching.

## Moving on to Action Caching

Action caching is an around filter for specific controller actions. It is
different from page caching since before filters are run and may prevent
access to certain pages. For example, you only want to cache if the user
is logged in. If the user is not logged in they should be redirect to
the log in page. This is different than page caching. Page caching
bypasses the rails stack completely. Most web applications for legitimate
complexity cannot use page caching. Action caching is the next logical
step for most web applications. Let's break the idea down: If the post
hasn't changed, return the entire cached page as the HTTP response, else
render the show view, cache it, and return that as the HTTP response. Or
in code:

```ruby
Rails.cache.fetch 'views/localhost:3000/posts/1' do
  @post = Post.find params[:id]
  render :show
end
```

Declaring action caching is easy. Here's how you can cache the show
action:

```ruby
class PostsController < ApplicationController

  caches_action :show

  def show
    # do stuff
  end
end
```

Now refresh the page and look at what's been cached.

    Started GET "/posts/2" for 127.0.0.1 at 2011-05-01 16:54:43 -0700
      Processing by PostsController#show as HTML
      Parameters: {"id"=>"2"}
    Read fragment views/localhost:3000/posts/2 (0.5ms)
    Rendered posts/show.html.erb within layouts/application (6.1ms)
    Write fragment views/localhost:3000/posts/2 (0.5ms)
    Completed 200 OK in 16ms (Views: 8.6ms | ActiveRecord: 0.1ms)

Now that the show action for post #2 is cached, refresh the page and see
what happens.

    Started GET "/posts/2" for 127.0.0.1 at 2011-05-01 16:55:27 -0700
      Processing by PostsController#show as HTML
      Parameters: {"id"=>"2"}
    Read fragment views/localhost:3000/posts/2 (0.6ms)
    Completed 200 OK in 1ms

Damn. 16ms vs 1ms. You can see the difference! You can also see Rails
reading that cache key. **The cache key is generated off the url with
action caching.** Action caching is a combination of a before and around
filter. The around filter is used to capture the output and the before
filter is used to check to see if it's been cached. It works like this:

1. Execute before filter to check to see if cache key exists?
2. Key exists? - Read from cache and return HTTP Response. This
   triggers a `render` and **prevents any further code from being
   executed.**
3. No key? - Call all controller and view code. Cache output using
   Rails.cache and return HTTP response.

Now you are probably asking the same question as before: "What do we do
when the post changes?" We do the same thing as before: we create a
composite key with a string and a time stamp. The question now is, how do
we generate a special key using action caching? 

Action caching generates a key from the current url. You can pass extra
options using the `:cache_path` option. Whatever is in this value is
passed into `url_for` using the current parameters. Remember in the
view cache key examples what happened when we passed in a hash? We got a
much different key than before: 

    views/localhost:3000/posts/2?hash_of_things

Rails generated a URL based key instead of the standard views key. This
is because you may different servers and things like that. This ensures
that each server has it's own cache key. IE, server one does not collide
with server 2. We could generate our own url for this resource by doing
something like this:

```ruby
url_for(@post, :tag => @post.updated_at.to_i)
```

This will generate this url:

    http://localhost:3000/posts/1?tag=234897123978

Notice the '?tag=23481329847'. Look familiar from anywhere? Rails uses
this method to tag GET urls for static assets. That way the browser does
not send a new HTTP request when it sees 'application.css?1234' since it
is caching it. We can use this strategy to with action caching as well.

```ruby
caches_action :show, :cache_path => proc { |c|
  # c is the instance of the controller. Since action caching
  # is declared at the class level, we don't have access to instance
  # variables. If cache_path is a proc, it will be evaluated in the
  # the context of the current controller. This is the same idea
  # as validations with the :if and :unless options
  #
  # Remember, what is returned from this block will be passed in as
  # extra parameters to the url_for method.
  post = Post.find c.params[:id]
  {:tag => post.updated_at.to_i}
end
```

This calls `url_for` with the parameters already assigned by it through
the router and whatever is returned by the block. Now if you refresh the
page, you'll have this:

    Started GET "/posts/2" for 127.0.0.1 at 2011-05-01 17:11:22 -0700
      Processing by PostsController#show as HTML
      Parameters: {"id"=>"2"}
    Read fragment views/localhost:3000/posts/2?tag=1304292445 (0.5ms)
    Rendered posts/show.html.erb within layouts/application (1.7ms)
    Write fragment views/localhost:3000/posts/2?tag=1304292445 (0.5ms)
    Completed 200 OK in 16ms (Views: 4.4ms | ActiveRecord: 0.1ms)

And volia! Now we have an expiring cache key for our post! Let's dig a
little deeper. We know the key. Let's look into the cache and see what
it actually is! You can see the key from the log. Look it up in the
cache.

    > Rails.cache.read 'views/localhost:3000/posts/2?tag=1304292445'
    => "<!DOCTYPE html>\n<html>\n<head>....."

It's just a straight HTML string. Easy to use and return as the body.
This method works well for singular resources. How can we handle the
index action? I've created 10,000 posts. It takes a good amount of time
to render that page on my computer. It takes over 10 seconds. The
question is, how can we cache this? We could use the most recently
updated post for the time stamp. That way, when one post is updated, it
will move to the top and create a new cache key. Here is the code
without any action caching:

    Started GET "/posts" for 127.0.0.1 at 2011-05-01 17:18:11 -0700
      Processing by PostsController#index as HTML
      Post Load (54.1ms)  SELECT "posts".* FROM "posts" ORDER BY updated_at DESC LIMIT 1
    Dalli::Server#connect localhost:11212
    Read fragment views/localhost:3000/posts?tag=1304292445 (1.5ms)
    Rendered posts/index.html.erb within layouts/application (9532.3ms)
    Write fragment views/localhost:3000/posts?tag=1304292445 (36.7ms)
    Completed 200 OK in 10088ms (Views: 9535.6ms | ActiveRecord: 276.2ms)

Now with action caching:

    Started GET "/posts" for 127.0.0.1 at 2011-05-01 17:20:47 -0700
      Processing by PostsController#index as HTML
    Read fragment views/localhost:3000/posts?tag=1304295632 (1.0ms)
    Completed 200 OK in 11ms

Here's the code for action caching:

```ruby
caches_action :index, :cache_path => proc {|c|
  post = Post.order('updated_at DESC').limit(1).first
  {:tag => post.updated_at.to_i}
}
```

These are simple examples designed to show you who can create auto
expiring keys for different situations. At this point we have not add to
expire any thing ourselves! The keys have done it all for us. However,
there are some times when you want more precise control over how things
exist in the cache. Enter Sweepers.

## Sweepers

Sweepers are HTTP request dependent observers. They are loaded into
controllers and observer models the same way standard observers do.
However there is one very important different. **They are only used
through HTTP requests.** This means if you have things being created
outside the context of HTTP requests sweepers will do you know good. For
example, say you have a background process running that syncs with an
external system. Creating a new model will not make it to any sweeper.
So, if you have anything cached. It is up to you to expire it.
Everything I've demonstrated so far can be done with sweepers. 

Each `cache_*` method has an opposite `expire_*` method. Here's the
mapping:

1. caches\_page , expire\_page
2. caches\_action , expire\_action
3. cache , expire\_fragment

Their arguments work the same with using cache key expansion to find a
key to read or delete. Depending on the complexity of your application,
it may be very to use sweepers or it may be impossible. Our simple
examples can use sweepers easily. We only need to tie into the save
event. For example, when a update or delete happens we need to expire
the cache for that specific post. When a create, update, or delete
happens we need to expire the index action. Here's what a the sweeper
would look like:

```ruby
class PostSweeper < ActionController::Caching::Sweeper
  observe Post

  def after_create(post)
    expire_action :index
    expire_action :show, :id => post
    # this is the same as the previous line
    expire_action :controller => :posts, :action => :show, :id => @post.id
  end
end

# then in the controller, load the sweeper
class PostsController < ApplicationController
  cache_sweeper :post_sweeper
end
```

I will not go into much depth on sweepers because they are the only
thing covered in the rails caching guide. The work, but I feel they are
clumsy for complex applications. Let's say you have comments for posts.
What do you do when a comment is created for a post? Well, you have to
either create a comment sweeper or load the post sweeper into the
comments controller. You can do either. However, depending on the
complexity of your model layer, it may quickly infeasible to do cache
expiration with sweepers. For example, let say you have a Customer. A
customer has 15 different types of associated things. Do you want to put
the sweeper into 15 different controllers? You can, but you may forget
to at some point. 

The real problem with sweepers is that they cannot be used once your
application works outside of HTTP requests. They can also be clumsy. I
personally feel it's much easier to create auto expiring cache keys and
only uses sweepers when I want to tie into very specific events.

Now you should have a good grasp on how the Rails caching methods work.
We've covered how fragment caching uses the current view to generate a
cache key. We introduced the concept of auto expiring cache keys using
`ActiveRecord#cache_key` to automatically expire cached content. We
introduced action caching and how it uses `url_for` to generate a cache
key. Then we covered how you can pass things into `url_for` to generate
a time stamped key to expire actions automatically. We've skipped page
caching because it's not applicable to many Rails applications. Now that
we understand how caching works we can address shortcomings in the
system.

## Moving Away from the HTTP Request

Now we're going to write some code to address problems in the Rails
caching system. We know that action caching is dependent on URLS.
Fragment caching is dependent on the view being rendered. However, we
know that both of these methods use `Rails.cache` under the covers to
store content. We can use `Rails.cache` any where in our code. Unlike
`caches_path`, `caches_action` and `cache` that will no hit the cache
if `perform_caching` is set to false, the `Rails.cache` methods will
**always** execute against the cache. Ideally, it would be nice to
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
information. Mailer do not. That's why the host name must be configured
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
# will not work in Rails 2 -- Rails 3 only!
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

## Tagged Based Caching

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
in. It is (my gem) that allows you associate actions and fragments with
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

The Ruby Standard Library comes with SHA1. SHA1 is good hashing function
so we'll have no problems using it for these examples. It takes a string
input and generates a hash. We'll create a composite key with a
timestamp and string representation of the input parameters.

```ruby
require 'digest/sha1'

class ComplicatedSearchController < ApplicationController

  caches_action :search, :cache_path => proc {|c|
    timestamp = Model.most_recently_updated.updated_at
    string = timestamp + c.params.inspect
    {:tag => Digest::SHA.hexdigest(string)}
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
    timestamp = Post.most_recently_updated.updated_at
    Rails.cache.fetch ['top-100', timestamp.to_i'].join('/') do
      order('vote_count DESC').limit(100).all
    end
  end
end
```

I've used the `most_recently_updated` method a few times. It is not a
defined method, but a method named so that you understand what it is
doing. We can use these concepts to do more fun stuff. My main project
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
Rails.cache to fetch different queries and keep them all cached. You can
wrap this functionality in a module and include in other associations.

```ruby
require 'digest/sha1'

module CachedFinderExtension
  def cached(options = {})
    key = Digest::SHA1.hexdigest(options.to_s)
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

You'll need to create a controller to server up some configuration
related information that's never cached. That way, a cached action will
load, then a separate request will be made for correct tokens. 

NOTE: You may run into more problems with on Rails 2. This is because
Rails 3 uses a form authenticity token and CSRF in a meta tag in the HEAD
of the document. This is for AJAX requests. You may notice the rails.js
file appends them to all AJAX requests. Forms submitted with AJAX with
something like `$(form).serialize()` will send the
`form_authenticty_token` since it's automatically included in all forms
generated with `form_for` or `form_tag`.


You need to create a new controller that responds_to JavaScript and
return some JS for the browser to evaluate. Here's how you can replace
the information in the meta tag for Rails 3. You can also use this
logic to update all `form_authenticty_token` inputs on the page.

    $("meta[name='csrf-token']").attr('content', '<% Rack::Utils.escape_html(request_forgery_protection_token) %>');
    $("meta[name='csrf-param']").attr('content', '<% Rack::Utils.escape_html(form_authenticity_token) %>');

    // you may also want to supply current application status as well.
    // for example, you may want to know the current users's ID
    // for use in your application JS
    MyApp.userId = '<%= current_user.id %>';


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

1. The honest to goodness best caching ever. Bypass Rails completely.
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
5. Only use sweepers when you have to.
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
