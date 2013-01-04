---
layout: post
title: "Advanced Caching: Part 3 - Static Assets"
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

Static assets are things that don't change. These are things like
JavaScript files, style sheets, and images. Caching and serving static
assets is a big aspect of any web application. They can be served
directly through Rack/Thin/Unicorn, through a web server like Nginx, or
through a CDN like Cloudflare. These options have been listed in slowest
first order. The objective for all of these strategies is to serve an
asset that can be cached indefinitely until the asset has changed.

## Static Asset Caching Strategies

This can be done through a combination of a few methods. Far future
expires is one method. FFE essentially set the age to 0 or set the
expire time to the maximum possible value (usually a year). Sprockets is
the asset server in Rails 3.1+. It uses fingerprinting (essentially
etags) to generate unique URLs for each asset. Fingerprinting generates
a URL like this: `/assets/application-9ea8d161dc03c8b77398d9e6e8ec452f.js`.
All the static asset helpers in Rails append the fingerprint in
production. So you'd see: `/assets/images/logo-9ea8d161dc03c8b77398d9e6e8ec452f.png`.
Assets can be requested in two different ways: with and without the
fingerprint. If the fingerprint (trailing hash) is given the response is
served with following headers:

```
Cache-Control: public, max-age=31536000
ETag: "fingerprint"
Last-Modified: timestamp
```

If the file is requested without the fingerprint:

```
ETag: "fingerprint"
Last-Modified: timestamp
Cache-Control: public, must-revalidate
```

The content is served with the `must-revalidate` flag because
`/assets/application.js` could refer to any fingerprint version. Setting
`must-revalidate` forces the user agent to check with the origin server
and make sure the content is the same.

## Handling Static Assets in Production

All assets need to be precompiled before deploying. All future
discussion assumes they are. This dumps all the assets into
`/public/assets`. This also means that all requests to
`/assets/application-fingerprint.js` are no longer going through your
application code. Remember `index.html`? That pesky file with every new
rails app that you have to delete? Assets are just like that. Rails
does not serve static assets by default in production. Here are some
common situation and ways to do this.

## Static Assets on Heroku (or any direct ruby process)

Heroku does not serve your application through a web server. Your
application has do all that work and handle responses. The Rails guides
describe how to configure Apache/Nginx, but don't describe how to handle
the situation yourself. Rails uses `ActionDispatch::Static` to serve
`/public`. This middleware is active then `config.serve_static_assets`
is `true`. `ActionDispatch::Static` takes an argument one argument: the value 
for the `Cache-Control` header. Annoyingly, this is not set by default 
in current rails applications. Older rails applications may have
`config.static_cache_control` present in `production.rb`. These steps
assume all your assets are finger printed.

1. Enable `config.serve_static_assets` in `production.rb`
2. Set `config.static_cache_control` to `public, max-age=31536000`
3. Redeploy

Now all requests to `/public/**/*.*` will be publicly cached with a
far future expire. This is the slowest way, but the only web possible if
you don't have access to a web server.

## Static Assets with a Nginx/Apache

Follow the Rails guides. This process is well documented. You
essentially configure the web server to add the headers itself.

## Static Assets with a CDN

Each CDN is different. They use some sort of internal and external
caching to deliver your assets quickly. I will not cover this in depth
because it's outside the scope of this guide, but all of them use HTTP
caching as described earlier.

## Index

1. [Caching Strategies](/2012/07/advanced_caching_part_1-caching_strategies)
2. [Using Strategies Effectively](/2012/07/advanced_caching_part_2-using_strategies)
3. [Handling Static Assets](/2012/07/advanced_caching_part_3-static_assets)
4. [Stepping Outside the HTTP Request](/2012/07/advanced_caching_part_4-stepping_outside_the_http_request)
5. [Tag Based Caching](/2012/07/advanced_caching_part_5-tag_based_caching)
6. [Fast JSON APIs](/2012/07/advanced_caching_part_6-fast_json_apis)
7. [Tips and Tricks](/2012/07/advanced_caching_part_7-tips_and_tricks)
8. [Conclusion](/2012/07/advanced_caching_part_8-conclusion)
