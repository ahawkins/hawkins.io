---
layout: post
title: "Advanced Caching: Part 5 - Tag Based Caching"
tags: [rails, tutorials]
hide: true
---

<p id="consulting-notice">
Are you experiencing performance problems in your application? Are you
unsure of how to cache things in your app? Or do you simply
have no clue where to start? I can solve these problems. <strong>I'll work one
on one with you on your app for 1 hour for $200 and make all that
uncertaintiy go away.</strong> <a href="mailto:me@broadcastingadam.com?subject=Caching%20Consultation">Contact me</a>
if you're interested.
</p>


Tag based caching is a way to solve the second hard problem in computer
science: cache invalidation. I was working on a complex application that
generated a ton of HTML. It was very repetitive in nature but highly
associative. The same data would be displayed on many different pages.
HTML fragments may need to reference many different objects to make it
all work. At this scale I could no longer think of individual fragments.
I could only think of the objects them selves. I simply wanted to
express this statement: expire everything associated with this contact.

Here's what I was dealing with:

1. Maintain control over how long things are cached
2. Large number of different associations. Actions or fragments no
   longer related to a specific resource. 
3. Content could be invalidated through HTTP requests or any number of
   background process.
4. Hard to maintain specific keys. I thought of it as "resources".

## Enter Cashier

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
the grouping logic.

Through all of this trickery, you'll be able to express this type of
statement:

```ruby
App.cache.expire_tag 'stats' 
App.cache.expire_tag @account
```

The content could from anywhere, but all you know is that's stale.

This is exactly where [Cashier](https://github.com/twinturbo/cashier) comes
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

I highly recommend you checkout [Cashier](https://github.com/twinturbo/cashier).
It may be useful in your application especially if you have complicated
relationships and high performance requirements.

## Index

1. [Caching Strategies](/2012/07/advanced_caching_part_1-caching_strategies)
2. [Using Strategies Effectively](/2012/07/advanced_caching_part_2-using_strategies)
3. [Handling Static Assets](/2012/07/advanced_caching_part_3-static_assets)
4. [Stepping Outside the HTTP Request](/2012/07/advanced_caching_part_4-stepping_outside_the_http_request)
5. [Tag Based Caching](/2012/07/advanced_caching_part_5-tag_based_caching)
6. [Fast JSON APIs](/2012/07/advanced_caching_part_6-fast_json_apis)
7. [Tips and Tricks](/2012/07/advanced_caching_part_7-tips_and_tricks)
8. [Conclusion](/2012/07/advanced_caching_part_8-conclusion)
