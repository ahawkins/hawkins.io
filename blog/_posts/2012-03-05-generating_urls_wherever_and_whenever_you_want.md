---
layout: post
title: "Generating URLs Whenever & Whenever You Want"
tags: [rails]
---

One of my big gripes with Rails is that it makes it very hard to do
things outside the request/response cycle. It is a web framework, but
now we have an increasing amount of things happening outside of that
workflow. You may have noticed that it's annoying to generate URLs
when you're not in a view or a controller. There is one simple reason
for this. They don't want to you to do that. There is also a reason 
why you cannot do that. The structure of the route helpers require 
the request because they know everything about where it came from, aka
they know the host. You need to know the host to generate urls and do
all that other stuff. If there is no request, there is no host.

ActionMailer is one very common case for generating URL's 
outside of request/response. Links inside emails need the full URL
because they don't live on webpage. This is why you have to set the
default url options to use route helpers inside mailers. So since
ActionMailer can generate URLs outside the request, we can do that do.
Most applications are going to have ActionMailer configured anyways, so
we can just piggy back off the configuration.

Here's an example `Router` class

    class Router
      include Rails.application.routes.url_helpers

      def self.default_url_options
        ActionMailer::Base.default_url_options
      end
    end

    router = Router.new
    router.posts_url  # http://localhost:3000/posts
    router.posts_path # /posts

    # all -2ez-

If you want to simply include routing support in any class you can
easily combine this into a module

    module Routing
      extend ActiveSupport::Concern
      include Rails.application.routes.url_helpers

      included do
        def default_url_options
          ActionMailer::Base.default_url_options
        end
      end
    end

    class UrlGenrator
      include Routing
    end

    generator = UrlGenerator.new
    generator.posts_url
    generator.posts_path

Happy routing!

