---
layout: post
title: Advanced Caching in Rails
tags: [rails, tutorials]
---

I've decided to finally update my advanced caching post. The original is
over a year old. It's still one of the most referenced and respected
posts on the subject. This revision is a refactor and upate all rolled
into one. I've decided to split the post into multiple parts due to
depth and length. I think all the content doesn't fit in a single post.
Splitting it up into different chapters allows people to skip to their
level or find relevant information. See the revision notes below for
more information.

## Index

1. Caching Strategies: HTTP, page, action, fragment, and `Rails.cache`
2. Using Strategies effectively
3. Stepping Outside the HTTP Request
4. Tag Based Caching
5. Tips and Tricks
6. Conclusion

## Revision Notes

### Cache Logging

This post was originally written for Rails 2. Some of log examples are
exstract from rails 2 applications. Rails 3 does **not** output any cache
information by default. There are two ways to see what's happening in
real time. 

1. Start a local memcached process with: `memached -vv`
2. Enable cache instrumentation and attach a log subscriber. Rails cache
   adatpers emit notifications through `ActiveSupport::Notifications`.
   These events can be logged. It's easy to attach a log subscriber. See
   this gist for an example. <~~~~ FIXME ~~~~>

I've elected to not update the log examples for Rails 3 because it does
not add any useful to the post. Following either of the methods above
will show you in real time what keys are written to cache. The only
thing that's changed is the formatting. Keep this in mind as you read
through the post.
