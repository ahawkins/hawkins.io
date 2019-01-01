---
title: "Repositories: Implementing Queries"
layout: redirect
redirect: "https://www.joyofdesign.info/2014/appendix/repository-pattern/queries/"
---

Fowler's repository pattern definition describes "selectors". A
selector defines criteria for loading objects. The repository could be
implemented purely using selectors. You may have a
`UniqueIdentifierSelector` or `LastObjectSelector` and domain specific
selectors such as `PopularPostsSelector`. Personally, I do not see the
need for the first two because have rigid semantics. This post focuses
on the `PopularPostsSelector` because that is domain specific and
requires manual implementation. I call these things "queries". This
post is about implementing on top of `Chassis`.

As you saw in the previous post on the public interface,
`Chassis::Repo` implements `query(klass, selector)`. The repo
delegates `query` to the proper manager class for resolution. The next
bit involves a small amount of meta programming. Since queries are
domain specific, they cannot be implemented in a shared way. The only
way to handle each query is to implement some code to handle it. I've
found a method per query is the easiest way. So when the repository
received the `PopularPostsSelector` it translates that to the
`query_popular_posts_selector` method and calls it. If that method is
not implemented, the repository will fail with a query not implemented
error. This is important since queries are domain specific they are
also implementation specific. The way you query data in an RDMS is not
the same as a key-value store, so it is plausible implementations may
have forgotten to implement some selectors. This where the library's
responsibility ends. It is your responsibility to fill in the method.
This also means you cannot use the pre-packaged implementations
anymore either. You must create your own.

Let's go through an example. First thing, create a class that contains
all the data needed to complete the query. `Struct` usually works fine
for this. Second, send the query to the repository for resolution. If
you're using Chassis right out of the box, the error messages will
guide you into completing the query.

```ruby
class Post
  include Chassis::Persistence
  attr_accessor :title, :text, :likes
end

PopularPosts = Struct.new :likes

class MyRepo < Chassis::MemoryRepo
end

repo = MyRepo.new

repo.query Post, PopularPosts.new(5) # Boom! raises an error
```

Now at this point you get an error and rightfully so. Chassis detected
that you have attempted a query which has no implementation. Chassis
cannot implement your queries, they are application specific. There is
no magic query interface. The repository receives the query then spits
out the correct data.

`MyRepo` is a generic memory repo. Queries can be implemented in a
more natural way. Since the instances are in memory, we can just
filter the active data set. A RDMS implementation would make some SQL
calls. A document-based implementation would do it's magic.

Each query is represented as a specific method. This is the default
behavior. You can change this before if you like. I've found it to be
just enough metaprogramming so it stays manageable. The select class
is `PopularPosts`. The repository should response to
`query_popular_posts`. Implement that method and return an array.

```ruby
class MyRepo
  def query_popular_posts(klass, q)
    all(klass).select do |post|
      post.likes >= q.likes
    end
  end
end
```

That's a wrap. I like this implementation because I know there is one
method completely responsible for each query. This makes it easy to
optimize reads because there is no generic query interface. This
approach also makes it painfully obvious what indexes you need
because all the queries are hitting you in the face.

Next we can encapsulate queries `Chassis::Repo::Delegation`.

```ruby
repo = MyRepo.new

# register and swap to our shiny repo
Chassis.repo.register :my_repo
Chassis.repo.use :my_repo

PopularPosts = Struct.new :likes

class PostRepo
  extend Chassis::Repo::Delegation

  class << self
    def popular(likes: 5)
      query PopularPosts.new(likes)
    end
  end
end

# Now you can use like so:

PostRepo.popular
PostRepo.popular likes: 10
```

This is how I work with things in practice. I prefer this layering
because it keeps my hidden from the low level details. It also makes
the wider application unaware of how querying works.
All classes access data via named methods on the per-class facades.

* [Back to Series](/2014/04/working_with_repositories)
* [Previous Post: The Public Interface](/2014/04/repositories-the-public-interface)
