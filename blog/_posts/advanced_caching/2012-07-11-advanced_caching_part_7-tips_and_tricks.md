---
layout: post
title: "Advanced Caching: Part 7 - Tips and Tricks"
tags: [rails, tutorials]
hide: true
---

This section is for random tips and tricks that don't really belong in
any other parts. They are related to any caching method.

## CSRF and form\_authenticty\_token

Rails uses a CSRF
(Cross Site Request Forgery) token and a form authentic token to
protect your application against attacks. These are generated per
request and each pages get unique values each time.
`protect_from_forgery` is added by default to `ApplicationController`.
You may have run into these problem before. You may have tried to submit
a POST and received an Unauthorized response. This is the
`form_authenticity_token` in action. You can fiddle with it and see what
happens to your application.

These tokens cause problems (depending on what Rails version you're
using) with cached HTML. Caching a form will
generate unauthorized errors because the tokens were for a different
session or request. There are parts of the cached pages that need to be
_replaced_ with new values before the application can be used. This is a
simple process, but it will take another HTTP request. 

You'll need to create a controller to serve up some configuration
related information that's never cached. That way, a cached action will
load, then a separate request will be made for correct tokens. 

You need to create a new controller that `responds_to` JSON and
return some JSON to handle in a jQuery callack. **Make sure this request
authenticates the current user!** It's also very important to **not**
use JavaScript for this! Cookies are sent with every request to JS which
may allow attackers to exploit your site.

Here's an abstract implemenation of the controller action

```ruby
# controller
def tokens
  authenticate! # do what you need to here
end
```

Now the view:

```ruby
# tokens.json.erb

{
  "token": "<% Rack::Utils.escape_html(request_forgery_protection_token) %>",
  "param": "<% Rack::Utils.escape_html(form_authenticity_token) %>"
}
```

And the jQuery code:

```javascript
$(function() {
  $.getJSON('/tokens.json', function(response) {
    $("meta[name='csrf-token']").attr('content', response.token);
    $("meta[name='csrf-param']").attr('content', response.param);
  });
})
```

See exploit [here](https://github.com/aaronjensen/advanced-caching-vulnerability).

## Bringing Caching into the Model Layer

Caching isn't just for views. Some DB operations or methods may be
computationally intensive. We can use `Rails.cache` inside the models to
make them more efficient. Let's say you wanted to cached the listing of
the top 100 posts on reddit.

```ruby
class Post
  def self.top_100
    timestamp = Post.maximum(:updated_at)
    Rails.cache.fetch ['top-100', timestamp.to_i'].join('/') do
      order('vote_count DESC').limit(100).all
    end
  end
end
```

## Dealing with Relative Dates (or other content)

Many Rails applications use `distance_of_times_in_words` throughout
their application. This can cause major problems for any cached content
with a dates. For example, you have a fragment cached. That fragment was
cached 1 month ago. 2 months ago, it's still in the cache. Since you
stored a relative date in the cache, the fragment contains '1 month
ago'. This is no good. You can solve this problem easily with
JavaScript.

JavaScript is better for handling dates/times than Rails is. This is
because Rails needs to know what the user's time zone is, then marshal
all times into that time zone. JavaScript is better because it use the
local time zone by default. How often do you want to display a time in a
different zone than user's current locale? You can dump the UTC
representation of the date into the DOM, then use JS to parse them into
relative or something like `strftime`. I've encapsulated this process in
a helper in my Rails applications. Once all the data is in the DOM, you
can do all the parsing in JavaScript.

```ruby
def timestamp(time, options = {})
  classes = %w(timestamp)
  classes << 'past' if time.past?
  classes << 'future' if time.future?

  options[:class] ||= ""
  options[:class] += classes.join(' ')

  content_tag(:span, time.utc.iso8601, options)
end
```

Then, when the page loads use a library like date.js to create
more user friendly dates.

## Index

1. [Caching Strategies](/2012/07/advanced_caching_part_1-caching_strategies)
2. [Using Strategies Effectively](/2012/07/advanced_caching_part_2-using_strategies)
3. [Handling Static Assets](/2012/07/advanced_caching_part_3-static_assets)
4. [Stepping Outside the HTTP Request](/2012/07/advanced_caching_part_4-stepping_outside_the_http_request)
5. [Tag Based Caching](/2012/07/advanced_caching_part_5-tag_based_caching)
6. [Fast JSON APIs](/2012/07/advanced_caching_part_6-fast_json_apis)
7. [Tips and Tricks](/2012/07/advanced_caching_part_7-tips_and_tricks)
8. [Conclusion](/2012/07/advanced_caching_part_8-conclusion)
