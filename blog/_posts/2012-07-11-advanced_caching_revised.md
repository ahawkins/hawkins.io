---
layout: redirect
title: "Advanced Caching in Rails: Revised"
tags: [rails, tutorials]
redirect: "https://railscaching.com"
---

I've decided to finally update my advanced caching post. The original is
over a year old. It's still one of the most referenced and respected
posts on the subject. This revision is a refactor and update all rolled
into one. I've decided to split the post into multiple parts due to
depth and length. I think all the content doesn't fit in a single post.
Splitting it up into different chapters allows people to skip to their
level or find relevant information. See the revision notes below for
more information.

## Purpose

This series means to teach you everything you need to know to implement
any different caching level inside your Rails application. It assumes
you know nothing at all about caching in any of its forms. It takes from
zero to knowledge to an intermediate level in all areas. If you can't
implement caching in your app after reading this then I've failed.

## Index

1. [Caching Strategies](/2012/07/advanced_caching_part_1-caching_strategies)
2. [Using Strategies Effectively](/2012/07/advanced_caching_part_2-using_strategies)
3. [Handling Static Assets](/2012/07/advanced_caching_part_3-static_assets)
4. [Stepping Outside the HTTP Request](/2012/07/advanced_caching_part_4-stepping_outside_the_http_request)
5. [Tag Based Caching](/2012/07/advanced_caching_part_5-tag_based_caching)
6. [Fast JSON APIs](/2012/07/advanced_caching_part_6-fast_json_apis)
7. [Tips and Tricks](/2012/07/advanced_caching_part_7-tips_and_tricks)
8. [Conclusion](/2012/07/advanced_caching_part_8-conclusion)

## Revision Notes

### Further Explantion of Cache Strategies

I've added a totally new section on HTTP caching. Page caching is
covered briefly. HTTP caching gets much more love in this
version. I'd like to push developers towards HTTP caching as much as
possible.

### Static Assets

Since HTTP caching was added I felt that it was only natural to cover
static assets. This aspect is usually left uncovered. Correctly handling
static assets is increasingly important as applications contain more and
more JS and CSS.

### Tag Based Caching & Sweepers

These sections have been slimmed down. I don't think they are as
important any more.

### Cache Logging

This post was originally written for Rails 2. Some of log examples are
extracted from Rails 2 applications. Rails 3 does **not** output any cache
information by default. There are two ways to see what's happening in
real time. 

1. Start a local memcached process with: `memached -vv` and watch
   $stdout.
2. Enable cache instrumentation and attach a log subscriber. Rails cache
   adatpers emit notifications through `ActiveSupport::Notifications`.
   These events can be logged. It's easy to attach a log subscriber. See
   the embedded gist:


### Cache Log Subscriber

<script src="https://gist.github.com/3086218.js"> </script>

I've elected to not update the log examples for Rails 3 because it does
not add any useful to the post. Following either of the methods above
will show you in real time what keys are written to cache. The only
thing that's changed is the formatting. Keep this in mind as you read
through the post.
