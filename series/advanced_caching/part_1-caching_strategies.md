---
layout: post
title: "Advanced Caching in Rails: Part 1 - Caching Strategies"
tags: [rails, tutorials]
---

First, let's start with a brief overview of the different types of
caching. We'll start from 50,000ft and work our way down.

1. HTTP Caching: Uses HTTP headers (`Last-Modified`, `ETag`,
   `If-Modified-Since`, `If-None-Match`, `Cache-Control`) to determine if the
   browser can use a locally stored version of the response or if it needs
   to request a fresh copy from the origin server. Rails makes it easy
   to use HTTP caching, however the cache is managed **outside** your
   application. You may have notice the `config.cache_control` and
   `Rack::Cache`, `Rack::ETag`, `Rack::ConditionalGet` middlewares. 
   These are used for HTTP caching.

2. Page Caching: **PRAISE THE GODS** if you actually can use page
   caching in your application. Page caching is the holy grail. Save
   the entire thing. Don't hit the stack & give some prerendered stuff
   back. Great for worthless applications without authentication and
   other highly dynamic aspects. This essentially works like HTTP
   caching, but the response will always contain the entire page. With
   page caching the application is skipping the work.

3. Action Caching: Essentially the same as page caching, except all
   the before filters are run allowing you to check authentication
   and other stuff that may have prevented the request form rendering.

4. Fragment Caching: Store parts of views in the cache. Usually for
   caching partials or large bits of HTML that are independent from
   other parts. IE, a list of top stories or something like that. 

5. Rails.cache: All cached content **except cached pages** are stored
   in the Rails.cache.  We'll use this fact that later.
   You can cache arbitrary content in the Rails cache. You may cache 
   a large complicated query that you don't want to wait to 
   reinstantiate a ton of `ActiveRecord::Base` objects.

## Under the Hood

All the caching layers are built on top of the next one. Page caching
and HTTP caching are different because they do not use `Rails.cache`
The cache is essentially a key-value store. Different
things can be persisted. Strings are most common (for HTML fragments).
More complicated objects can be persisted as well. Let's go through some
examples of manually using the cache to store things. I am using
memcached with dalli for all these examples. Dalli is the default
memcached driver.

```
# Rails.cache.write takes two values: key and a value
> Rails.cache.write 'foo', 'bar'
=> true

# We can read an object back
> Rails.cache.read 'foo'
=> "bar"

# We can store a complicated object as well
> hash = { :this => { :is => 'a hash' }}
> Rails.cache.write 'complicated-object', object
> Rails.cache.read 'complicated-object'
=> {:this=>{:is=>"a hash"}}

# If we want something that doesn't exist, we get nil
> Rails.cache.read 'we-havent-cached-this-yet'
=> nil

# "Fetch" is the most common pattern. You give it a key and a block
# to execute to store if the cache misses. The blocks's return value is
# then written to the cache. The block is not executed if there is a
# hit.
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

Those are the basics of interacting with the Rails cache. The rails
cache is a wrapper around whatever functionality is provided by the
underlying storage system. Now we are ready to move up a layer.

## Understanding Fragment Caching

Fragment caching is taking rendered HTML fragments and storing them in
the cache. Rails provides a `cache` view helper for this. Its most
basic form takes no arguments besides a block. Whatever is rendered
during the block will be written back to the cache. The basic principle
behind fragment caching is that it takes much less time fetch
pre-rendered HTML from the cache, then it takes to generate a fresh copy.
This is appallingly true. If you haven't noticed, view generation can be very
costly. If you have cachable content and are not using fragment caching
then you need to implement this right away! Let's say you have generated a 
basic scaffold for a post:

```
$ rails g scaffold post title:string content:text author:string
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
```

Let's say we wanted to cache fragment. Simply wrap it in `cache` and
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
<% end %>
```

The first argument is the key for this fragment. The rendered HTML is
stored with this key: `views/posts-1`. Wait what? Where did that 'views'
come from? The `cache` view helper automatically prepends 'views' to all
keys. This is important later. When you first load the page you'll see
this in the log:

```
Exist fragment? views/post-2 (1.6ms)
Write fragment views/post-2 (0.9ms)
```

You can see the key and the operations. Rails is checking to see if the
specific key exists. It will fetch or write it. In this case, it has
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

This is a very simple problem. What if we could figure out a
solution to this problem: How can we create a cache miss when the
associated object changes? We've already demonstrated how we can
explicitly set a cache key. What if we made a key that's dependent on the
time the object was last updated? We can create a key composed of the
record's ID and its `updated_at` timestamp! This way the cache key will
change as the content changes **and we will not have to expire things
manually.** (We'll come back to sweepers later). Let's change our cache
key to this:

```erb
<% cache "post-#{@post.id}", @post.updated_at.to_i do %>
```

Now we can see we have a new cache key that's dependent on the object's
timestamp. Check out the rails log:

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
timestamp. You can see this in action by `touch`'ing a post.

```
Post.find(1).touch

Exist fragment? views/post-2/1304292445 (0.4ms)
Write fragment views/post-2/1304292445 (0.4ms)
```

This concept is known as: **auto expiring cache keys.** You create a
composite key with the normal key and a time stamp. This will create some
memory build up as objects are updated and no longer fresh.
Here's an example. You have that fragment. It is cached. Then someone updates
the post. You now have two versions of the fragment cached. If there are
10 updates, then there are 10 different versions. Luckily for you, this
is not a problem for memcached! Memcached uses a LRU replacement policy.
LRU stands for Least Recently Used. That means the key that hasn't been
requested in the longest time will be replaced by newer content when
needed. For example, assume your cache can only hold 10 posts. The
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
method, a different key is generated. For the time being, this code is
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
access to certain pages. For example, you may only want to cache if the user
is logged in. If the user is not logged in they should be redirected to
the log in page. This is different than page caching. Page caching
bypasses the rails stack completely. Most web applications of legitimate
complexity cannot use page caching. Action caching is the next logical
step for most web applications. Let's break the idea down: If the post
hasn't changed, return the entire cached page as the HTTP response, else
render the show view, cache it, and return that as the HTTP response. Or
in code:

```ruby
# Note: you cannot run this code! This is just an example of what's
# happening under the covers using concepts we've already covered.
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
reading that cache key. **The cache key is generated from the url with
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
view cache key examples what happened when we passed in a hash? We get a
much different key than before: 

    views/localhost:3000/posts/2?hash_of_things

Rails generated a URL based key instead of the standard views key. This
is because you may different servers. This ensures
that each server has it's own cache key. IE, server one does not collide
with server two. We could generate our own url for this resource by doing
something like this:

```ruby
url_for(@post, :tag => @post.updated_at.to_i)
```

This will generate this url:

    http://localhost:3000/posts/1?tag=234897123978

Notice the `?tag=23481329847`. This is a hack that aims to stop browsers
from using HTTP caching on specific urls. If the URL has changed
(timestamp changes) then the browser knows it must request a fresh copy.
Rails 2 used to do this for assets like CSS and JS. Things have changed
with the asset pipeline.

Here's an example of generating a proper auto expring key for use with
action caching.

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
  { :tag => post.updated_at.to_i }
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
  { :tag => Post.maximum('updated_at') }
}
```

We'll come back to this situation later. This is a better way to do
this. Points to the reader if they know the problem.

These are simple examples designed to show you who can create auto
expiring keys for different situations. At this point we have not had to
expire any thing ourselves! The keys have done it all for us. However,
there are some times when you want more precise control over how things
exist in the cache. Enter Sweepers.

## Sweepers

Sweepers are HTTP request dependent observers. They are loaded into
controllers and observe models the same way standard observers do.
However there is one very important different. **They are only used
during HTTP requests.** This means if you have things being created
outside the context of HTTP requests sweepers will do you no good. For
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
it may be easy to use sweepers or it may be impossible. It's easy to use
sweepers with these examples. We only need to tie into the save
event. For example, when a update or delete happens we need to expire
the cache for that specific post. When a create, update, or delete
happens we need to expire the index action. Here's what the sweeper
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
complexity of your model layer, it may quickly become infeasible to do cache
expiration with sweepers. For example, let say you have a Customer. A
customer has 15 different types of associated things. Do you want to put
the sweeper into 15 different controllers? You can, but you may forget
to at some point.

The real problem with sweepers is that they cannot be used once your
application works outside of HTTP requests. They can also be clumsy. I
personally feel it's much easier to create auto expiring cache keys and
only uses sweepers when I want to tie into very specific events. I'd
also argue that any well designed system does not need sweepers (or at
least in very minimally).

Now you should have a good grasp on how the Rails caching methods work.
We've covered how fragment caching uses the current view to generate a
cache key. We introduced the concept of auto expiring cache keys using
`ActiveRecord#cache_key` to automatically expire cached content. We
introduced action caching and how it uses `url_for` to generate a cache
key. Then we covered how you can pass things into `url_for` to generate
a time stamped key to expire actions automatically. Now that we
understand these lower levels we can move up to page caching and HTTP
caching.

## Page Caching

Page caching bypasses the entire application by serving up a file in
/public from disk. It is different from action or fragment caching for a
two reasons: content is not stored in memory and content is stored
directly on the disk. You use page caching the same way you use action
caching. This means you can use sweepers and and all the other things
associated with them. Here's how it works.

* Webserver accepts an incoming request: `GET /posts`
* File exists: `/public/posts.html`
* `posts.html` is returned
* Your application code is never called.

Since pages are written like public assets they are served as such. You
will expliclity have to expire them. Warning! Forgetting to expire pages
will cause you greif because you application code will not be called.
Here's an example of page caching:

```ruby
PostsController < ApplicationController
  caches_page :index
  
  def index
    # do stuff
  end
```

When the server receives a request to `GET /posts` it will write the
response from the application to `/public/posts.html`. The `.html` part
is the format for that request. For example you can use page caching
with JSON. `GET /posts.json` would generate `/public/posts.json`.

Page caching is basically poor man's HTTP caching without any real
benefits. HTTP caching is more useful. 

I've not covered page caching in much depth because it's very likely
that if you're reading this page caching is not applicable to your
application. The Rails guides cover page caching in decent fashion.
Follow up there if you need more information.

## HTTP Caching

HTTP caching is the most complex and powerful caching strategy you can
use. With great power comes great responsiblity. HTTP caching works at
the protocol level. You can configure HTTP caching so the browser
doesn't even need to contact your server at all. There are many ways
HTTP caching can be configured. I will not cover them all here. I will
give you an overview on how the system works and cover some common use
cases.

### How It Works

HTTP caching works at the protocol level. It uses a combination of
headers and response codes to indicate weather the user agent should
make a request or use a locally stored copy instead. The invalidation
or expiring is based on `ETags` and `Last-Modified` timestamps. `ETag` stands
for "entity tag". It's a unique fingerprint for this request. It's usually
a checksum of the respnose body. Origin
servers (computers sending the source content) can set either of these
fields along with a `Cache-Control` header. The `Cache-Control` header tells
the user agent what it can do with this response. It answers questions
like: how long can I cache this for and am I allowed to cache it? When
the user agent needs to make a request again it sends the `ETag` and/or
the `Last-Modified` date to the origin server. The origin server decides
based on the `ETag` and/or `Last-Modified` date if the user agent can use
the cached copy or if it should use new content. If the server says use
the cached content it will return status 304: Not Modified (aka fresh). 
If not it should return a 200 (cache is stale) and the new content
which can be cached.

Let's use curl to see how this works out:

```
$ curl -I http://www.example.com
HTTP/1.1 200 OK
Cache-Control: max-age=0, private, must-revalidate
Content-length: 822
Content-Type: text/html
Date: Mon, 09 Jul 2012 22:46:29 GMT
Last-Modified: Mon, 09 Jul 2012 21:22:11 GMT
Status: 200 OK
Vary: Accept-Encoding
Connection: keep-alive
```

The `Cache-Control` header is a tricky thing. There are many many ways
it can be configured. Here's the two easiest ways to break it down:
private means only the final user agent can store the response. Public
means any server can cache this content. (You know requests may go
through many proxies right?). You can specify an age or TTL. This is how
long it can be cached for. Then there is another common situation: Don't
check with the server or do check with the server. This particular
`Cache-Control` header means: this is a private (think per user cache)
and check with the server everytime before using it. 

We can trigger a cache hit by sending the apporiate headers with the
next request. This response only has a `Last-Modified` date. We can send
this date for the server to compare. Send this value in the
`If-Modified-Since` header. If the content hasn't changed since that date
the server should return a 304. Here's an example using curl:

```
$ curl -I -H "If-Modified-Since: Mon, 09 Jul 2012 21:22:11 GMT" http://www.example.com
HTTP/1.1 304 Not Modified
Cache-Control: max-age=0, private, must-revalidate
Date: Mon, 09 Jul 2012 22:55:53 GMT
Status: 304 Not Modified
Connection: keep-alive
```

This response has no body. It simply tells the user agent to use the
locally stored version. We could change the date and get a different
response.

```
$ curl -I -H "If-Modified-Since: Sun, 08 Jul 2012 21:22:11 GMT" http://www.example.com
HTTP/1.1 200 OK
Cache-Control: max-age=0, private, must-revalidate
Content-length: 822
Content-Type: text/html
Date: Mon, 09 Jul 2012 22:57:19 GMT
Last-Modified: Mon, 09 Jul 2012 21:22:11 GMT
Status: 200 OK
Vary: Accept-Encoding
Connection: keep-alive
```

Caches determine freshness based on the `If-None-Match` and/or
`If-Modified-Since` date. Using our existing 304 response we can supply
a random etag to trigger a cache miss:

```
$ curl -I -H 'If-None-Match: "foo"' -H "If-Modified-Since: Mon, 09 Jul 2012 21:22:11 GMT" http://www.example.com
HTTP/1.1 304 Not Modified
Cache-Control: max-age=0, private, must-revalidate
Date: Mon, 09 Jul 2012 22:55:53 GMT
Status: 304 Not Modified
Connection: keep-alive
```

`Etag`s are sent using the `If-None-Match` header. Now that we understand
the basics we can move onto higher level discussion.

### Rack::Cache

HTTP caching is implemented in the webserver itself or at the
application level. It is implemented at the application level in Rails.
`Rack::Cache` is a middleware that sits at the top of the stack and
intercepts requests. It will pass requests down to your app and store
their contents. Or will it call down to your app and see what `ETag`
and/or timestamps it returns for validation purposes. `Rack::Cache` acts
as a proxy cache. This means it must respect caching rules described in
the `Cache-Control` headers coming out of your app. This means it cannot
cache private content but it can cache public content. Cachable content
is stored in memcached. Rails configures this automatically.

I'll cover one use case to illustrate how code flows through middleware
stack to the actual app code and back up. Let's use a private per user
cache example. Here's the cache control header: `max-age-0, private,
must-revalidate`. Pretend this is some JSON API.

1. The client sends initial request to `/api/tweets.json`
2. `Rack::Cache` sees the request and ignores it since there is no caching
   information along with it.
3. Application code is called. It returns a 200 response with a date and
   the some `Cache-Control` header.
4. The client makes another request to `/api/tweets.json` with an
   `If-Modified-Since` header matching the date from the previous
   request.
5. `Rack::Cache` sees that his request has cache information associated
   with it. It checks to see how it should handle this request.
   According to the `Cache-Control` header it has expired and needs to
   be checked to see if it's ok to use. `Rack::Cache` calls the
   application code.
6. Application returns a response with the same date.
7. `Rack::Cache` recieves the response, compares the dates and determines
   that it's a hit. `Rack::Cache` sends a 304 back.
8. The client uses response body from request in step 1.

### HTTP Caching in Rails

Rails makes it easy to implement HTTP caching inside your controllers.
Rails provides two methods: `stale?` and `fresh_when`. They both do the
same thing but in opposite ways. I prefer to use `stale?` because it
makes more sense to me. `stale?` reminds more of `Rails.cache.fetch` so
I stick with that. `stale?` works like this: checks to see if the
incoming request `ETag` and/or `Last-Modified` date matches. If they
match it calls `head :not_modified`. If not it can call a black of code
to render a response. Here is an example:

```ruby
def show
  @post = Post.find params[:id]
  stale? @post do
    respond_with @post
  end
end
```

Using `stale?` with an `ActiveRecord` object will automatically set the
`ETag` and `Last-Modified` headers. The `Etag` is set to a MD5 hash of the
objects `cache_key` method. The `Last-Modified` date is set to the object's
`updated_at` method. The `Cache-Control` header is set to `max-age=0,
private, must-revalidate` by default. All these values can be changed by
passing in options to `stale?` or `fresh_when`. The methods take three
options: `:etag`, `:last_modified`, and `:public`. Here are some more
examples:

```ruby
# allow proxy caches to store this result
stale? @post, :public => true do
  respond_with @post
end

# Let's stay your posts are frozen and have no modifications
stale? @post, :etag => @post.posted_at do
  respond_with @post
end
```

Now you should understand how HTTTP caching works. Here are the
important bits of code inside Rails showing it all works.

```ruby
# File actionpack/lib/action_controller/metal/conditional_get.rb, line 39
def fresh_when(record_or_options, additional_options = {})
  if record_or_options.is_a? Hash
    options = record_or_options
    options.assert_valid_keys(:etag, :last_modified, :public)
  else
    record  = record_or_options
    options = { :etag => record, :last_modified => record.try(:updated_at) }.merge(additional_options)
  end

  response.etag          = options[:etag]          if options[:etag]
  response.last_modified = options[:last_modified] if options[:last_modified]
  response.cache_control[:public] = true if options[:public]

  head :not_modified if request.fresh?(response)
end
```

Here is the code for `fresh?`. This code should help you if you are
confused on how resquests are validated. I found this code much easier
to understand than the official spec.

```ruby
def fresh?(response)
  last_modified = if_modified_since
  etag          = if_none_match

  return false unless last_modified || etag

  success = true
  success &&= not_modified?(response.last_modified) if last_modified
  success &&= etag_matches?(response.etag) if etag
  success
end
```
