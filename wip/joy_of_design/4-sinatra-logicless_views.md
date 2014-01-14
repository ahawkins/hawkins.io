---
title: "Delivery Mechanisms with Sinatra - Logicless Views"
layout: post
---

All the discussion up to this point has been around JSON generation.
Unfortunately, not every application is 100% communication. I've come
across a recent pattern in my work. There is a web services that
exists. It communicates with others with JSON. Then there is a human
facing admin part that does _something_. This something is really
troublesome because it greatly inflates the scope. Now the delivery
mechanism has to deal with assets, rendering templates, possible
translations, and god knows what else. User facing applications
simply require a lot more stuff.

To be honest I usually just consider this junk. After all they can
just write their own API client and make some UI they want right? Hey
marketing knows how to program right? We can dream right. These
responsibilites tend to butt up against the perfect world of
testable functional requirements. User interfaces also have the
highest churn rate of any part in an application. How many times have
this request come across your desk: "can you _just_ add this column?"
or "can you _just_ add a button for $FEATURE?". The requests always
start with "just"--like it should be easy. I emphasized just because
that's usually where the emphasis is. People external to the code
usually assume it is easy. We programmers know inherently you cannot
_just_ do something. There are always problems in the way. Why do we
have a natural aversion to such tasks? Is it because we see them as
less important or are they usually so hard that they're depressing?

I think it is probably more with the latter. Why do they become so
hard? The answer is fucking views (we think templates on the web). And
why fucking views? Because views tend to encapsulate so many parts of
the application because many things connect there. Then they grow to
contain logic, helpers are added to make the logic easier, and in the
worse case the most logical part of an entire system. I have not
worked on a ruby application that does not have some sort of logic in
a view. This is why we groan when we think about these things. We
immediately think to ourselves "need to change this here, that there,
oh need to format this thing, then get more data from the db, oh
_blah_.". So how can we _just_ do it?

The answer is to make the view the stupidest object in the entire
system. In this business we call these "logicless views." There is a
never ending battle to make user interfaces more complex. Luckily you
can use good design principles to your advantage.

This starts by creating an object that encapsulates everything a given
view needs to display itself. The template may only access this one
object. All data must be explicitly declared. Second you must choose a
templating language. There are many choices in Ruby. In my opinion
there are two choices: ERB and Mustache. ERB has a serious problem. It
is Ruby. It's possible to write an entire application inside an ERB
template. If you decide to go with ERB you **must** continually beware
of this and fight against it. Mustache is a great choice in theory
because it is **impossible** to add logic into templates. However this
may be too extreme for some people. I personally prefer Mustache on
principle. It also gives you the ability (if important) to share
templates between server and client. However I choose ERB in practice
because it is part of the standard library and with judicious uses and
good practice is just as good as Mustache. Also note by providing an
object that encapsulates all the information the templating language
is not as important. With all that said, it's finally time to get to
the code.

## View Models

We have a naming problem in the community. These objects are known by
many names. You may have called them "presenters", "view models", or
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
the understandability or flexibility? It hasn't for me. This is
another example of continually fighting against bring more
dependencies into a project. Code someone else writes is the hardest
to maintain.

These classes usually end in `Page` because people usually talk about
"the xxx page." This makes the mapping between nontechnical and
technical work easier. The page will undoubtably contain
subcomponents. A nested class is used there. This keeps everything for
that page inside a given namespace.

It's easy to use the object. Sinatra uses instance variables to share
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
<link rel="stylesheet" href="<%= @view.stylesheet_url %> />
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
not completely logicless in this regard. You can write `{{{thing}}}`
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
<link rel="stylesheet" href="<%= url(@view.stylesheet_url) %> />
```

This is the most logic I put into the templates. It's also easy to see
when the `url` helper should be used because the method named end in
`_url`. It keeps things sane without putting too much responsibility
into the templates.

This solution is not possible in Mustache because it does not have
access to Ruby code. There would need to be a bunch of trickery
involved to get access to the `url` helper in the view objects.

## Where this Shines

* translations
* rendering lists
