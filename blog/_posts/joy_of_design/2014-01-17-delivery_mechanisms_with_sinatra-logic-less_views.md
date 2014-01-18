---
title: "Delivery Mechanisms with Sinatra - Logic-less Views"
layout: post
---

All the discussion up to this point has been around JSON generation.
Unfortunately, not every application is 100% JSON. I've come
across a pattern in my work. There is a web services that
exists. It communicates with JSON. Then there is a human
facing admin part that does _something_. This thing is really
troublesome because it greatly inflates the scope. Now the delivery
mechanism has to deal with assets, rendering templates, possibly
translations, and god knows what else. User facing applications
simply require a lot more stuff.

To be honest I usually just consider this junk. After all they can
just write their own API client and make some UI they want right? These
responsibilities tend to butt up against the perfect world of
testable functional requirements. User interfaces also have the
highest churn rate of any part in an application. How many times have
this request come across your desk: "can you _just_ add this column?"
or "can you _just_ add a button for $FEATURE?". The requests always
start with "just"--like it should be easy. I emphasized just because
that's usually where the emphasis is. People external to the code
usually assume it is easy. We programmers know inherently you cannot
_just_ do something. There are always some problems. Why do we
have a natural aversion to such tasks? Is it because we see them as
less important or are they usually so hard that they're depressing?

I think it is probably more with the latter. Why do they become so
hard? The answer is fucking views (we think templates on the web). And
why fucking views? Because views tend to encapsulate so many parts of
the application because many things connect there. Then they grow to
contain logic, helpers are added to make the logic easier, and in the
worse case the most logical part of the entire system. I have not
worked on a ruby application that does not have some sort of logic in
a view. This is why we groan when we think about these things. We
immediately think to ourselves "need to change this here, that there,
oh need to format this thing, then get more data from the db, oh
_blah_.". So how can we _just_ do it?

The answer is to make the view the stupidest object in the entire
system. In this business we call these "logic-less views." There is a
never ending battle to make user interfaces more complex. Luckily you
can use good design principles to your advantage.

This starts by creating an object that encapsulates everything a given
view. The template may only access this 
object. All data must be explicitly declared. Second you must choose a
templating language. There are many choices in Ruby. In my opinion
there are two choices: ERB and Mustache. ERB has a serious problem. It
is Ruby. It's possible to write an entire application inside an ERB
template. If you decide to go with ERB you **must** continually be
aware
of this and fight against it. Mustache is a great choice in theory
because it is **impossible** to add logic into templates. However this
may be too extreme for some people. I personally prefer Mustache on
principle. It also gives you the ability (if important) to share
templates between server and client. However I choose ERB in practice
because it is part of the standard library and with judicious use and
best practices it is just as good as Mustache. When providing an
object that encapsulates all the information, the templating language
is not as important. With all that said, it's finally time to get to
the code.

## View Models

There is a naming problems. These objects are known by
many names. You have called them "presenters", "view models", or
"decorators." The name does not matter. They are classes that
encapsulate all the data needed to display something. Constructing
them is easy. Define a class and define reader methods.

```ruby
class AdminPage
  def initialize(model)
    @model = model
  end

  def title
    I18n.translate 'admin_page.title'
  end

  def style_sheet_url
    '/assts/admin.css'
  end

  def javascript_url
    '/assets/admin.js'
  end

  def user_admin_url
    '/admin/users'
  end

  def stats
    @model.total_photos
  end
end
```

The class defines **everything**. That was easy. There is no reason to
use any of these sort of presenter/view model/decorator libraries. I
have not seen them provide any significant benefit over this approach.
This approach is simple and direct. How could using a library increase
the understandability or flexibility? It will not. This is
another example of continually fighting against bring more
dependencies into a project. Code someone else writes is the hardest
to maintain.

These classes usually end in `Page` because people usually talk about
"the xxx page." This makes the mapping between nontechnical and
technical discussion easier. The page will undoubtedly contain
subcomponents. Use a nested class. This keeps everything for
that page inside a given namespace.

It's easy to use this object. Sinatra uses instance variables to share
data with templates. ERB makes it possible to reach other instance
variables so be sure to set only one! Here's an example:

```ruby
class AdminApp < Sinatra::Base
  get '/admin' do
    stats = GetApplicationsStatistics.new(current_user).run!

    @view = AdminPage.new stats
    render :admin_page
  end
end
```

Writing the template is easy. Just call the view's methods.

```
<!-- markup -->
<link rel="stylesheet" href="<%= @view.stylesheet_url %>" />
<!-- markup -->
<p>Total Photos: <%= @view.total_photos %>
```

And so on and so forth. You'll notice the templates are actually quite
readably. They will definitely be less intimidating.

## Lessons Learned from Writing Templates

There are a few places where it is ok to have logic in a views. But
wait? You just said don't do that. Yes I did. However everything in
software is a compromise. We must constantly measure trade offs. HTML
escaping is an example. Should the view model do all the escaping or
does the view know when data should be escaped or not? In my
experience it's easier to let the view handle this. Even mustache is
not completely logic-less in this regard. You can write `{{{thing}}}`
which will use the raw value. Values with `{{thing}}` are escaped. ERB
does nothing. My applications define the `h` helper. It escapes HTML.
The template can decide when to use it. This provides flexibility
while keeping logic to a bare minimum. Defining this helper is easy:

```ruby
class WebService < Sinatra::BAse
  helpers do
    def h(text)
      Rack::Utils.escape_html text
    end
  end
end
```

Then you can use like so:

```
<h1><%=h @view.title %></h1>
```

There is another pain point I've come across. It is hard to generate
url's outside the route handler. Generating URLs depends on the
context of the specific request. This is especially problematic if
you're using a URL map because "/" means too completely different
things. Does it mean "domain.com/" or "domain.com/where-im-mounted/"?
This is exactly Sinatra has a `url` helper. It takes in a string path
and spits out the appropriate URL. However this needs the current
`env` hash. So if you want to generate a URL inside these view model
classes you must pass in the `env`. Then you need to get a hold of the
`url` method. Or you can simply generate all the urls in the route
handler. This is less than ideal because it defeats the purpose of a
view model. Again there is a compromise to be made. In the view model
example there are methods for `style_sheet_url` and `javascript_url`.
These methods return the arguments for the `url` helper. This approach
works well because the path is context free. The view model can handle
generating more complicated paths with parameters and no state is
needed. Sinatra implicitly exposes `url` so nothing is needed there. I
think this is a fair and useful compromise. If we revisit a template
for the described view you'd end up with a template like this:

```
<link rel="stylesheet" href="<%= url(@view.stylesheet_url) %>" />
```

This is the most logic I put into the templates. It's also easy to see
when the `url` helper should be used because the method named end in
`_url`. It keeps things sane without putting too much responsibility
into the templates.

This solution is not possible in Mustache because it does not have
access to Ruby code. There would need to be a bunch of trickery
involved to get access to the `url` helper in the view objects.

## Where this Shines

There are a few significant places where this approach really shines.
I'll point out some examples I've seen.

This approach makes handling translations dead easy. The template
does not know that the content _is_ translated. This
provides a few subtle benefits.
First, it keeps all key names outside the template, and thus logic
that will inevitably spread into more places. Second, it makes complex
key derivation easy. How many have you needed to generate a
translation key using properties from some other
object(s)? I'm talking about stuff like this:
`I18n.translate("foo.bar.#{thing.type}.#{other_thing.kind}")` or had
default logic or other behavior? All of this logic happens in the view
model. Third, it makes things more testable. If such complex logic
exists you can easily test the view model's reader method's return
values. It's also easy to assert that view model uses simple
translation keys as well. Fourth, having a view model makes it easier
to migrate to a translated UI in the future. Here is some example
code:

```ruby
class PhotoPage
  def initialize(photo, locale = I18n.default_locale)
    @photo, @locale = photo, locale
  end

  def popularity
    if photo.views? >= 1000
      translate 'photo.views.popular'
    elsif photo.views? >= 300
      translate 'photo.views.rising'
    else
      translate 'photo.views.working_on_it'
    end
  end

  def title
    translate "photo_page.title.#{photo.category}.#{photo.location}"
  end

  private
  def translate(key)
    I18n.translate(key, raise: true, locale: locale)
  end

  def locale
    @locale
  end

  def photo
    @photo
  end
end
```

I prefer to pass the locale like this instead of relying on global
variables. Using the global for the default works makes things work
easier in the real world. I also prefer to use the `raise` option.
This will raise an error and make tests fail if keys are missing.
Shipping code with missing translations is not acceptable.

View models also make rendering complex substructures easy. Lists or
tables are common. In this case the view model provides a
reader method that supplies an array of view models. Naturally this is
especially useful when the data provided does not map 1-1 with what
should be displayed. Here's an example:

```ruby
class PhotosPage
  class PhotoPresenter
    def initialize(photo)
      @photo = photo
    end

    def popularity
      if photo.views? >= 1000
        translate 'photo.views.popular'
      elsif photo.views? >= 300
        translate 'photo.views.rising'
      else
        translate 'photo.views.workign_on_it'
      end
    end

    def favorite_url
      "/photos/#{photo.id}/favorites"
    end

    def photographer
      photo.user.nick
    end
  end

  def initialize(photos)
    @photos = photos
  end

  def photos
    @photos.map { |photo| PhotoPresenter.new photo }
  end
end
```

## Everything Must be Explicit

I use `private` for all view models. The template may only access data
through the public interface. Everything the template needs is
provided a by single method. This keeps things used to initialize the
object outside the public scope. I do not use any proxy objects for
this purpose for the same reason. A proxy allows the template to call
methods not explicitly defined. Imagine if `photo` where a domain
object. It may have a method that mutates state. That method should
not accessible to templates. This is why `PhotoPresenter` does not use
`SimpleDelegator` or another proxy object.

## Final Notes

It is hard so sum up everything there is about logic-less views in a
single post. I hope this post had enough information to wet your
whistle and convince you to move your applications in this direction.
This approach has made maintaining my applications much easier.

The next post is about composing larger web services with multiple
Sinatra applications.
