---
layout: post
title: "Advanced Caching: Part 2 - Using Caching Strategies"
tags: [rails, tutorials]
hide: true
---

Using caching effectively can be tricky and frustrating. The best
solution (like most things in programming) is to take a little bit of
everything to make your own secret sauce. Here are some general
recommendations:

* Use HTTP caching everywhere. This cuts down on bandwidth. No other
  caching strategy can do this. Users on subpar connections (read:
  mobile users) will see a major benefit because they will not have to
  download the entire page again. This can amount of MB of savings when
  interacting with specific applications.
* You can ignore page and action caching when using HTTP
  caching. They do the same thing but less effectively.
* Use the Russian doll approach when rendering complex views
* Use `Rails.cache` inside models to improve performance of common and
  costly operations.
* Use auto expiring cache keys for **everything**.

Let's take that advice and apply a multi-layered strategy to a blog.

## Our Blog

Our blog is simple. It has a main page which lists all the posts with
their meta data. The post page has the entire content, a list of
comments, and some general sidebar type stuff. This is a very common
layout. We'll use HTTP caching in the front and Russian doll fragment
caching in the back. This is fastest way you can do it because: 
initial requests will fill the cache with all the individual HTML
fragments then that response will be cached locally. Subsequent invalid
requests will be composed of existing cached fragments saving time in
HTML generation and validation.

Here's our initial controller:

```ruby
PostsController < ApplicationController
  respond_to :html

  def index
    @posts = Post.all
    respond_with @posts
  end

  def show
    @post = Post.find params[:id]
    respond_with @post
  end
end
```

Here's the initial views

```erb
<% @posts.each do |post| %>
  <p>
    <%= link_to post.author, author_path(post.author) %>
    <%= link_to post.title, post_path(post) %><br \>
    <%= truncate post.body %>
    <%= post.comments.count %><%= pluralize "comments", post.comments.count %>
  </p>
<% end %>
```

```erb
<% div_for @post do %>
  <h1><%= post.title %></h1>
  <%= complex_format @post.body %>
  <% render :partial => 'signature', :locals => { :author => @post.author }} %>

  <h2>Comments</h2>
  <% @post.comments.each do |comment| %>
    <p><%= comment %></p>
  <% end %>
<% end %>

<% render 'sidebar' %>
```

Now that we have the initial controller and views we can start to make
them more performant. I've taken some liberties with the view code to
introduce more content and render a partial. Rendering partials can be
expensive due to binding creation and other things. These views are not
inherently complex. They do provide a simple use case to see how methods
can be applied.

## Step 1: Fragment Caching the View

Let's start with easiest things to do. Cache the individual components
of the view.

```erb
<% @posts.each do |post| %>
  <% cache post, 'main-listing' %>
    <p>
      <%= link_to post.author, author_path(post.author) %>
      <%= link_to post.title, post_path(post) %><br \>
      <%= truncate post.body %>
      <%= post.comments.count %><%= pluralize "comments", post.comments.count %>
    </p>
  <% end %>
<% end %>
```

```erb
<% div_for @post do %>
  <% cache post, 'main-content' %>
    <h1><%= post.title %></h1>
    <%= complex_format @post.body %>
    <% render :partial => 'signature', :locals => { :author => @post.author }} %>
  <% end %>

  <% cache post, 'comments' do %>
    <h2>Comments</h2>
    <% @post.comments.each do |comment| %>
      <p><%= comment %></p>
    <% end %>
  <% end %>
<% end %>

<% cache 'sidebar' %>
  <% render 'sidebar' %>
<% end %>
```

I've simply wrapped the individual sections in cache blocks. Each block
uses auto expiring cache keys for the post with another string to
indicate what it is. Now going to these pages would hit the cache and
save some time.

Now apply the Russian doll technique. It's easy to see that a post's
page would change when a new comment is added. The post's content hasn't
changed though. `complex_format` may be an expensive operation that we
don't want to perform again. We can cache one large chunk that will
expire. The large chunk is composed of smaller cacheable chunks. What we
can do now is wrap the views in one entire cache block.

```erb
<% cache @post %>
  <% div_for @post do %>
    <% cache post, 'main-content' %>
      <h1><%= post.title %></h1>
      <%= complex_format @post.body %>
      <% render :partial => 'signature', :locals => { :author => @post.author }} %>
    <% end %>

    <% cache post, 'comments' do %>
      <h2>Comments</h2>
      <% @post.comments.each do |comment| %>
        <p><%= comment %></p>
      <% end %>
    <% end %>
  <% end %>

  <% cache 'sidebar' %>
    <% render 'sidebar' %>
  <% end %>
<% end %>
```

Now we have views composed of individual chunks! It's overkill in this
use case but the point is illustrated. Now let's move onto HTTP caching
in the controller.

## Step 2: HTTP Caching in the Controller

```ruby
def show
  @post = Post.find params[:id]

  if stale? @post do
    respond_with @post
  end
end
```

Voila! That was easy. We have HTTP caching and fragment caching for the
individual post pages. Now we can tackle the index pages. These are
slightly more complex because the view depends on many records. The
number of comments on each posts is displayed in the list. What happens
when one post gets a new comment? Well we have to display something
differently.

## Step 3: Caching Views Generated from Arrays

We need to generate a cache key that factors in all the
records. The cache key also needs to be auto expiring. Let's define a
method on `Post` that does just that.

```ruby
require 'digest/md5'

class Post
  def cache_key
    Digest::MD5.hexdigest "#{maximum(:updated_at).try(:to_i)-#{count}"
  end
end
```

This method is easy to understand: generate a unique hash based on the
most recently updated record and how many records are present. This
makes the key auto expire when a record is added, updated (given
`updated_at` is changed), and a record is deleted. We factor in the
count to make deletions work. Deleting records would not change the key
without count. Assume you deleted the very first post. The most recently
updated post would set the timestamp and it would cause a hit. We wrap
the whole entire thing in a MD5 so any change will generate a unique
cache key. Now we can update the index view.

```erb
<% cache @posts # this works now because @posts defines cache_key %>
  <% @posts.each do |post| %>
    <% cache post, 'main-listing' %>
      <p>
        <%= link_to post.author, author_path(post.author) %>
        <%= link_to post.title, post_path(post) %><br \>
        <%= truncate post.body %>
        <%= post.comments.count %><%= pluralize "comments", post.comments.count %>
      </p>
    <% end %>
  <% end %>
<% end %>
```
Implementing HTTP caching is easy as well. It is not reliable to use
timestamps (`Last-Modified` and `If-Modified-Since`) because of the
issues previously described. It's easier to use etags in this case.
ETags will ensure that each request to `GET /posts` will have unique
fingerprint based on all the underlying posts. We'll use the `cache_key`
method for the `ETag`.

```ruby
def index
  @posts = Post.scoped
  if stale? @posts do
    respond_with @posts
  end
end
```

And that's all we have to do there. 

## Step 5: Comments Touch Posts 

Comments must touch Posts to make everything work. This code will change
a post's timestamp whenever a comment is updated. This will also change
the cache key for arrays of posts.

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post, :touch => true
end
```

Now we've acheived the holy grail. Any change in the data layer will
auto expire everything in the view layer. We don't have to handle the on
the hard problems (tm) in computer science: cache invalidation.

## Handling Code Changes

Everything described so far works perfectly when the data changes. What
happens when you want to deploy a new version of your blog? This is a
very good question. Without any additional configuration you'd have key
collisons. The cache doesn't know that is a difference between today's
deploy and yesterday's deploy.

We can solve this problem with auto expiring keys. All the cache keys
must factor in some meta data about the current deploy. All higher level
cache calls eventually go through
`ActiveSupport::Cache.expand_cache_key` as described earlier. This
method checks if`ENV["RAILS_CACHE_ID"]` or `ENV["RAILS_APP_VERSION"]` is
present and factors them into the key. All we have to do from a
deployment perspective is update these environment variables after each
deploy. The easiest way is to set it to the SHA of the current commit.

Here's a command you can execute during your deployment:

```
$ export RAILS_APP_VERSION=$(git rev-parse --short HEAD)
```

This will not work for all deployments but you get the idea. This has an
interesting side effect. If you rollback your deployment, it will switch
back to the cache for that version.

## Index

1. [Caching Strategies](/2012/07/advanced_caching_part_1-caching_strategies)
2. [Using Strategies Effectively](/2012/07/advanced_caching_part_2-using_strategies)
3. [Handling Static Assets](/2012/07/advanced_caching_part_3-static_assets)
4. [Stepping Outside the HTTP Request](/2012/07/advanced_caching_part_4-stepping_outside_the_http_request)
5. [Tag Based Caching](/2012/07/advanced_caching_part_5-tag_based_caching)
6. [Fast JSON APIs](/2012/07/advanced_caching_part_6-fast_json_apis)
7. [Tips and Tricks](/2012/07/advanced_caching_part_7-tips_and_tricks)
8. [Conclusion](/2012/07/advanced_caching_part_8-conclusion)
