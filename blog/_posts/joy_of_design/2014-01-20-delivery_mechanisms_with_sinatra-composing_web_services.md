---
title: "Delivery Mechanisms with Sinatra - Composing Web Services"
layout: redirect
redirect: "https://www.joyofdesign.info/2014/delivery-mechanisms/composing-web-services/"
---

Web applications usually handle different responsibilities. There may
be a JSON API component, something handling sessions, and another part
handling webhooks from the public internet. Each responsibility has
its own constraints and optimizations. Quickly go over the use cases
for the components just described. Do you think it makes sense to dump
them all into one class? Perhaps if the surface area is small enough.
In practice I split them up into individual classes because then each
may evolve at its own pace inside the larger system.  Once I started
doing this, large systems became easier to maintain and understand.

## How It Works

You've probably already done this without knowing it. Have you ever used
Resque or Sidekiq's web UI? Then you've done it. Have you ever used a
rails engine with controllers/etc? Then you've done it. Rack makes
this extremely easy with `Rack::URLMap`. `Rack::Builder`
includes a `map` method it more convenient. Here's an example
`config.ru`:

```ruby
map '/' do
  run JsonServer
end

map '/admin' do
  run AdminInterface
end

map '/stats' do
  run StatsInterface
end
```

Naturally you can insert middleware before the apps. You might want
something like this:

```ruby
map '/' do
  run JsonServer
end

map '/admin' do
  use Rack::Auth::Basic, "Admin Area" do |user, password|
    password == 'secret'
  end

  run AdminInterface
end

map '/stats' do
  use Rack::Auth::Basic, "Stats Area" do |user, password|
    password == 'secret'
  end

  run StatsInterface
end
```

This makes composing large web applications possible.

## Real World Use Cases

I started doing this in Radium. It happened when a requirement came in
that clearly divided the application into two different systems. One
was completely stateless. It was only available to authenticated user
requests and simply returned JSON. The second handled signups and
logins. We had an existing Ember frontend but we could not use it for
this because we needed server OAuth integration. This meant the server
part also required sessions and had to accept unauthenticated requests
from the public internet. I did not want to add any crap for sessions
or cookies to the JSON part, but they were required for signup/login.
I also did not want to to add any asset logic to the JSON part either.
Conversely I did not want to have to do conditional authentication in
the sign up part of the app. So I split them into two different
applications and tested them as such. Each was a Sinatra application.
Here is what the code generally looked like:

```ruby
class WebService < Sinatra::Base
  disable :sessions

  use TokenAuth
  # and so on with more middleware related to this responsibility
  use JsonParsing
end
```

```ruby
class SignupApp < Sinatra::Base
  enable :sessions

  set :public_path "/path/to/some/public/directory"
  set :view_path "/path/to/some/templates"

  helper do
    # some helpers to make rendering templates easier
  end

  use OAuth

  get '/start' do
    # render template that kicks off the wizard
  end

  # other helper routes to make make the Ember singup
  # wizard work correctly.
end
```

From there it is straight forward to map them correctly:

```ruby
# config.ru
map '/' do
  run WebService
end

map '/signup' do
  run SignupApp
end
```

That's all there really is too it! This also made testing easier since
each app was testable in complete isolation. Testing was also more
straight forward because semantics from other parts of the app did not
leak into tests for the others.

The next and final post on delivery mechanisms covers
[testing](/2014/01/delivery_mechanisms_with_sinatra-testing/)
with `rack-test`.
