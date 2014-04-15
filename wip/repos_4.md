---
title: "Repositories: Implementing Queries"
layout: post
--

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

Let's go through an example.
