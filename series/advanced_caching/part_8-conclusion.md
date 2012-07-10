---
layout: post
title: "Advanced Caching in Rails: Part 8 - Conclusion: Cashing Out"
tags: [rails, tutorials]
---

I've covered a ton of material in this article. I've given a through
explanation of how all the Rails cache layers fit together and how to
use the lowest level to it's full potential. I've provided a solution
for managing the cache outside the HTTP request cycle as well as shown
you how to bring caching into the model layer. This is not the
be-all-and-end-all Rails caching. It is a in-depth look at caching in a
Rails application. I'll leave you with a quick summary of everything
covered and some few goodies.

## HTTP Caching

1. Very Handy! You should strive to reach this goal
2. Cuts down on bandwidth when requests are fresh
3. Cacheable responses are stored in `Rack::Cache`
4. Uses `ETag` with `If-None-Match` and/or `Last-Modified` with `If-Modified-Since`
   date to check freshness

## Page Caching

1. The simplest that could possibly work
2. Usually not applicable to any web application. Have a form? No good,
   the `form_authenticity_token` will be no good and Rails will reject
   it

## Action Caching

1. Most bang for the buck. Can usually be applied in many different
   circumstances
2. Uses fragment caching under the covers
3. Generates a cache key based off the current URL and whatever other
   options are passed in
4. Get more mileage by caching actions with an composite timestamped
   key

## Fragment Caching

1. Good for caching reusable bits of HTML or JSON. Think shared partials or
   forms
2. Use a good cache key for each cache block.
3. Don't go overboard. Requests to memcached are not free. Maximize
   benefits by caching a small number of large fragments instead of a
   large number of small fragments.

## General Points

1. Don't worry about sweepers unless you have too.
2. Understand the limitations of Rail's HTTP request cycle 
3. Use cryptographic hashes to generate cache keys when permutations of
   input parameters are involved
4. Don't be afraid to use `Rails.cache` in your data layer
6. Tagged based caching is useful in certain situations
7. Consolidate your cache expiration logic in one place so it's easily
   testable.
8. Test with caching turned on in complex applications.
9. Look into [Varnish](http://www.varnish-cache.org/) for more epic
   wins.
10. belongs to with `:touch => true` is your friend
11. Use association timestamps
12. Spend time upfront considering your cache strategy
13. Be weary of examples with expire by regex. This only works on cache
    stores that have the ability to iterate over all keys. **Memcached**
    is not one of those
14. **Use auto expiring keys for everything!**
15. Understand how cache validation and expiration works according to
    the HTTP caching spec.
16. Cache your static assets! If possible, serve them through a CDN
17. In rare situations, excessive calls to memcached may be **slower**
    than skipping it.
18. Consider the current locale when caching HTML.
19. **Don't** forget to set `ENV['RAILS_APP_VERSION']` on every deploy

I really hope you learned and enjoyed this guide. It has been a fun to
right and I know it has helped a ton of Rails developers.
