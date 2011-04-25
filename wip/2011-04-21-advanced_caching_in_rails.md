---
layout: post
title: Advanced Caching in Rails
tags: [rails, tutorials]
---

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

## Sweepers: LOL WUT

Part of this tutorial revolves making it easier to do caching in your
application. Many guides like to throw around sweepers all day. Sweepers
have their uses. However, most of the time you **don't need a sweeper.**
This because we can construct the cache key in such a way that it
changes as the object is updated. This is exactly how
`ActiveRecord::Base#cache_key` works. You may not be familiar with this
method. It basically constructs a key like:

    posts/1/123847192387 # last key is @post.updated_at.to_i

So say we had some thing like this in the view

    <% cache @post do %>
      <%= render :partial => 'posts/post', :locals => {:post => @post} %>
    <% end %>

The cache method will expand the arguments using the `cache_key` method
and generate a key like `views/some_file/posts/1/132487328` and store
the result of the block in the cache with that key. We all know by now
that a blog post will have many comments (mostly spam though :( )

    class Post < ActiveRecord::Base
      has_many :comments
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

Then in the posts partial we have something along these lines:

    <h2><%= h(@post.title) %></h2>
    <%= simple_format(@post.content) %>

    <% post.comments.each do |comment| %>
      <%= simple_format(comment.message) %>
    <% end %>

So what happens when a comment is made? We know we have to expire the
that fragment. Question is how? Well, we just tell the comment to touch
the post when it's updated. This will change the post's `cache_key` and
thusly **cause a cache miss** the next time it is request causing the
partial to be rerendered. Simply add `:touch => true` to the
`belongs_to` association like so:

    class Comment < ActiveRecord::Base
      belongs_to :post, :touch => true
    end

Whenever a comment is created/saved/updated/destroyed the post's
`updated_at` method will change causing a miss. This concept is known as
**autoexpiring cache keys**. This is wonderful! Simply because declaring
some options in the model layer will make it easier to main performance
in the view layer. This works out very nicely in memcached because it
uses an LRU (Least Recently Used) replacement policy. That means, when
its alloted memory is fill it will make room by deleting the oldest
blocks. Everytime a cache hit occurs, it is moved to the top of the
list. If a key is never requested it will slowly move to the bottom the
stack and be dumped (aka evicted) when something new needs to be stored.

## Getting More Milage from Fragment Caching

I use fragment caching a ton. There are situtations where you want to
display the same data a different way. It may be a list of posts, or who
know what--it's just a different view of the same data. If you were
using a sweeper, you'd have to keep track of all the different actions
that could change the data and sweep accordingly. Luckily for Rails
programmers, it's very easy to construct cache keys on the fly so you
never have to worry about **what they actually are.** We'll come back to
this point later. 

Here's our scenario: We have a large fragment that contains the post. 
We also have a large fragment for metadata and other random stuff in the
sidebar. It contains the number of comments, tags, and some other stuff.
For this example, _it's just stuff_. 

Assume we have two partials:

    /views/posts/_post
    /views/posts/_meta

This fragments are represenative of the underlying data and will to be
expired at the same time. We can create a custom cache key for each
framgent like this:

    <% cache [@post, 'main'] %>
      # render the partial
    <% end %>

    <% cache [@post, 'meta' %] %>
      <%= render :partial => 'meta', :locals => {:post => @post} %>
    <% end %>


This will generate two keys: `views/something/posts/1/132132487/main`
and `views/something/posts/1/132132487/meta`. You can use this to cache
many different fragments. Note: I've used a random string of numbers for
the timestamp. 

You can also call `cache` with no arguments will used the context of the
request to fill in a cache key. This is how the Rails [docs](http://api.rubyonrails.org/classes/ActionController/Caching/Fragments.html) demonstrate it. They also illustrate
how you can use call `expire_fragment` in the sweeper to invalidate
it--but now we know a trick around that. 

These fragment caching examples are **not** a good way to actually cache
this kind of content. They are merely provided as a example of how you
can generate auto-expiring cache keys for your various view fragments. A
Blog post is the perfect place to apply action caching. Odds, are the
page with the post doesn't change much except there filters in place.

## Auto Expiring w/Action Caching

We can use auto expiring keys just as before with action caching. Let's
take a look at a simple controller for showing the post. As an example,
we'll have a before filter that tracks how many people have been to this
page. 

    class PostsController < ApplicationController
      before_filter :update_view_counter

      def show
        @post = post
      end

      def post
        Post.find params[:id]
      end

      private
      def update_view_counter
        # do stuff
      end
    end

We can easily cache the entire action without any extra effort--and
we'll never have to sweep it ourself. Here's how:

    before_filter :update_view_counter

    caches_action :post, :cache_path => proc do |c|
      # c is the instance of the controller handling the request
      c.post_url(c.post, :tag => c.post.updated_at.to)
    end

And there ya have it! Now whenever anyone tries to go to that page will
generate a cache key like: `example.com/posts/1?tag=1238478174`. Options
returned by the `:cache_path` proc will be passed into a route helper
similar to `post_path`. Basically, we end up with a key that's equal to
calling: `post_path(@post, :tag => 132489739847)`. That was easy. You
can throw as many parameters (I like to think of them as tags) in there
as you like as long as you don't overflow your cache store's key limits.
You may never run into this problem, but there are situtations where you
might. 

## Actions with Many Query Parameters

Let's say have a complicated index type action where you allow the user
to create all sorts of cool conditions, limits, paginations, orderings,
and all that jazz on a user's posts. We can cache all these different
combinations using action caching. We know that each combination of
input parameters has to be cached with a different key than the others.
We also do not want to worry about expiring the pages since there are a
ton of different combos. Let's take a look at a general controller:

    class PostsController < ApplicationController

      def index
        @posts = filtered_posts
      end

      private
      def filtered_posts
        # load users posts
        #
        # I'll leave this code out since you have a good idea
        # of what it's like to write some nice case statements
        # and other code with a ton of branches :)
        #
        # apply more complicated filter logic
        #
        # return posts
      end
    end

How can we generate a unique key for each combination of input
parameters? Use a secure cryptographic hash. A secure hash means there
are no collisions. This means we will not have a key conflict--IE a
search ordered by the post date and one by the number of comments will
never have the same key. We can take all the parameters and dump them
into a hashing function (along with the user's timestamp) to generate an
auto expiring key for all combinations of search parameters! Here's the
code

    require 'digest/sha1'
    class PostsController < ApplicationController
      # make sure post belongs_to :user, :touch => true

      caches_action :index, :cache_path => proc do |c|
        timestamp = User.find(c.params[:user_id]).to_i
        tag = Digest::SHA1.hex_digest(c.params.to_s + timestamp.to_s)
        posts_url(tag)
      end

      # ....
    end

Now we'll get a key like: `example.com/posts?tag=e3282090ae22d23113ab038ce188ae334cc51df7`.
Granted, you cannot discern what the key is for, but you can cache every
combination of input parameters. Not bad for four lines of code.
