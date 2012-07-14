---
layout: post
title: Rack from the Beginning
tags: [rack, tutorials]
---

Rack is the HTTP interface for Ruby. Rack defines a standard interface
for interacting with HTTP and connecting web servers. Rack makes it easy
to write HTTP facing applications in Ruby. Rack applications are shockingly
simple. There is the code that accepts a request and code serves the
response. Rack defines the interface between the two.

## Dead Simple Rack Applications

Rack applications are objects that respond to `call`. They must return a
"triplet". A triplet contains the status code, headers, and body. Here's
an example class that shows "hello world."

```ruby
class HelloWorld
  def response
    [200, {}, 'Hello World']
  end
end
```

This class is not a Rack application. It demonstrates what a triplet
looks like. The first element is the HTTP response code. The second is a
hash of headers. The third is an enumerable object representing the
body. We can use our hello world class to create a simple rack app. We
know that we need to create an object that responds to call. `call`
takes one argument: the rack environment. We'll come back to the `env`
later.

```ruby
class HelloWorldApp
  def self.call(env)
    HellowWorld.new.response
  end
end
```

I've made a simple class that implements `call`. It returns the
response from the `HelloWorld` class. Now we need to put this
online. We have implemented one side of the wall. Now we need write the
other side. Rack includes a `Server` class. This is the simplest way to
serve rack applications. It includes daemonization and things like that.
It works but it's not meant from production applications! Let's create a
simple ruby script to serve `HelloWorldApp`

```ruby
# hello_world.rb
require 'rack'
require 'rack/server'

class HelloWorld
  def response
    [200, {}, 'Hello World']
  end
end

class HelloWorldApp
  def self.call(env)
    HelloWorld.new.response
  end
end

Rack::Server.start :app => HelloWorldApp
```

Here's what happens when you run this script:

```
$ ruby hello_world.rb
>> Thin web server (v1.4.1 codename Chromeo)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:8080, CTRL+C to stop
```

Simply open `http://localhost:8080` and you'll see "Hello World" in the
browser. It's not fancy but you just wrote your first rack app! We
didn't write our own server and that's ok. Matter of fact, that's
fantastic. Odds are you will never need to write your own server. There
are plenty of servers to choose from: Thin, Unicorn, Rainbows, Goliath,
Puma, and Passenger. You don't want to write those. You want to write
applications. That's what we wrote.

## Env

I skipped over over what `env` is in the previous section. That's
because we didn't need it yet. The `env` is a `Hash` that meets the rack
spec. You can read the spec [here](http://rack.rubyforge.org/doc/SPEC.html). 
It defines **incoming** information. Outgoing data must be
triplets. The `env` gives you access to incoming headers, host info,
query string and other common information. The `env` is passed to the
application which decides what to do. Our `HelloWorldApp` didn't care
about it. Let's update our `HelloWorldApp` to interact with incoming
information.

```ruby
class HelloWorldApp
  def self.call(env)
    [200, {}, "Hello World. You said: #{env['QUERY_STRING']}"]
  end
end

Rack::Server.start :app => HelloWorldApp
```

Now visit `http://localhost:8080?message=foo` and you'll see
"message=foo" on the page. If your more curious about `env` you can do
this:

```ruby
class EnvInspector
  def self.call(env)
    [200, {}, env.inspect]
  end
end

Rack::Server.start :app => EnvInspector
```

Here's the tl;dr of what basic `env` looks like. It's just a standard
Hash instance.

```ruby
{
  "SERVER_SOFTWARE"=>"thin 1.4.1 codename Chromeo",
  "SERVER_NAME"=>"localhost",
  "rack.input"=>#<StringIO:0x007fa1bce039f8>,
  "rack.version"=>[1, 0],
  "rack.errors"=>#<IO:<STDERR>>,
  "rack.multithread"=>false,
  "rack.multiprocess"=>false,
  "rack.run_once"=>false,
  "REQUEST_METHOD"=>"GET",
  "REQUEST_PATH"=>"/favicon.ico",
  "PATH_INFO"=>"/favicon.ico",
  "REQUEST_URI"=>"/favicon.ico",
  "HTTP_VERSION"=>"HTTP/1.1",
  "HTTP_HOST"=>"localhost:8080",
  "HTTP_CONNECTION"=>"keep-alive",
  "HTTP_ACCEPT"=>"*/*",
  "HTTP_USER_AGENT"=>
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11",
  "HTTP_ACCEPT_ENCODING"=>"gzip,deflate,sdch",
  "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.8",
  "HTTP_ACCEPT_CHARSET"=>"ISO-8859-1,utf-8;q=0.7,*;q=0.3",
  "HTTP_COOKIE"=> "_gauges_unique_year=1;  _gauges_unique_month=1",
  "GATEWAY_INTERFACE"=>"CGI/1.2",
  "SERVER_PORT"=>"8080",
  "QUERY_STRING"=>"",
  "SERVER_PROTOCOL"=>"HTTP/1.1",
  "rack.url_scheme"=>"http",
  "SCRIPT_NAME"=>"",
  "REMOTE_ADDR"=>"127.0.0.1",
  "async.callback"=>#<Method: Thin::Connection#post_process>,
  "async.close"=>#<EventMachine::DefaultDeferrable:0x007fa1bce35b88
}
```

You may have noticed that the `env` doesn't do any fancy parsing. The
query string wasn't a hash. It was the string. The `env` is raw
data. I like this design principle a lot. Rack is very simple to
understand and use. If you wanted you could only work with hashes and
triplets. However that's just tedious. Complex applications need
abstractions. Enter `Rack::Request` and `Rack::Response`. 

## Abstractions

`Rack::Request` is an abstraction around the `env` hash. It provides
access to thinks like cookies, POST paramters, and other common things. It
removes boiler plate code. Here's an example.

```ruby
class HelloWorldApp
  def self.call(env)
    request = Rack::Request.new env
    request.params # contains the union of GET and POST params
    request.xhr?   # requested with AJAX
    require.body   # the incoming request IO stream

    if request.params['message']
      [200, {}, request.params['message']]
    else
      [200, {}, 'Say something to me!']
    end
  end
end
```

`Rack::Request` is simply a proxy for the `env` hash. The underlying
`env` hash is modified so keep that in mind.

`Rack::Response` is an abstraction around generating response triplets.
It simplifies access to headers, cookies, and the body. Here's an
example:

```ruby
class HelloWorldApp
  def self.call(env)
    response = Rack::Response.new
    response.write 'Hello World' # write some content to the body
    response.body = ['Hello World'] # or set it directly
    response['X-Custom-Header'] = 'foo'
    response.set_cookie 'bar', 'baz'
    response.status = 202

    response.finish # return the generated triplet
  end
end
```

These are basic abstractions. They don't require much explanation. You
can learn more about them by reading the documentation.

Now that we have some basic abstractions we can start to make more
complex applications. It's hard to make an application when all the
logic is contained in one class. Applications are always composed of
different classes. Each class has a single responsibility. This is
the SRP (Single Responsibility Principle). These discrete chunks are
called "middleware".

## Middleware

Rack applications are simply objects that respond to `call`. We can do
whatever we want inside `call`, for instance we can delegate to another
class. Here's an example:

```ruby
class ParamsParser
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new env
    env['params'] = request.params
    app.call env
  end
end

class HelloWorldApp
  def self.call(env)
    parser = ParamsParser.new self
    env = parser.call env
    # env['params'] is now set to a hash for all the input paramters

    [200, {}, env['params'].inspect] 
  end
end
```

I admit this example is quite contrived. You want not do this in
practice. The point is to illustrate that you can manipulate env (or
response). You can create a middleware
stack as deep as you like. Each middleware simply calls the next one and
returns its value. This is an example of the builder pattern. Composing
Rack applications is so common (and required) that Rack includes a class
to make this easy. Before we move to the next step, let's define what
a middleware looks like:

```ruby
class Middleware
  def initialize(app)
    @app = app
  end

  # This is a "null" middlware because it simply calls the next one.
  # We can manipulate the input before calling the next middleware
  # or manipulate the response before returning up the chain.
  def call(env)
    @app.call env
  end
end
```

## Composing Rack Apps from Middleware

`Rack::Builder` creates up a middleware stack. Each object calls
the next one and returns its return value. Rack contains a bunch of handy
middlewares. They have one for caching and encodings. Let's increase
the `HelloWorldApp`'s performance.

```ruby
# this returns an app that responds to call cascading down the list of 
# middlewares. Technically there is no difference between "use" and
# "run". "run" is just there to illustrate that it's the end of the 
# chain and it does the work.
app = Rack::Builder.new do 
  use Rack::Etag            # Add an ETag
  use Rack::ConditionalGet  # Support Caching
  use Rack::Deflator        # GZip
  run HelloWorldApp         # Say Hello
end

Rack::Server.start :app => app
```

`app` has a `call` method that generates this call tree:

```
Rack::Etag
  Rack::ConditionalGet
    Rack::Deflator
      HelloWorldApp
```

I'm not going to cover what those middlewares do because that's not
important. This is an example of how you can build up functionality in
applications. Middlewares are very powerful. You can add manipulate
incoming data before hitting the next one or modify the response from
an existing one. Let's create some for practice.

```ruby
class EnsureJsonResponse
  def initialize(app)
    @app = app
  end

  # Set the 'Accept' header to 'application/json' no matter what.
  # Hopefully the next middleware respects the accept header :)
  def call(env)
    env['HTTP_ACCEPT'] = 'application/json'
    @app.call env
  end
end
```

```ruby
class Timer
  def initialize(app)
    @app = app
  end

  def call(env)
    before = Time.now
    status, headers, body = @app.call env

    headers['X-Timing'] = (Time.now - before).to_i.to_s

    [status, headers, body]
  end
end
```

Now we can use those middlewares in our app.

```ruby
app = Rack::Builder.new do 
  use Timer # put the timer at the top so it captures everything below it
  use EnsureJsonResponse
  run HelloWorldApp
end

Rack::Server.start :app => app
```

We've just written our own middeware and learned how to generate a
runnable application with a middleware stack. This is how rack apps are
written in practice. Now onto the final piece of the puzzle: `config.ru`

## Rackup

You may have seen the `rackup` command referenced before. It's provided
by the rack gem. It provides a simple way to start a web process using
one of the rack servers installed on the system. It looks for
`config.ru` by default. `config.ru` defines what ruby code the server
should call. It's wrapped in a `Rack::Builder` as shown before. Here's
all the work we've done up to now in `config.ru`

```ruby
# config.ru

# HelloWorldApp defintion
# EnsureJsonResponse defintion
# Timer definition

use Timer
use EnsureJsonResponse
run HelloWorldApp
```

Now navigate into the correct directory and run: `rackup` and you'll
see:

```
$ rackup
>> Thin web server (v1.4.1 codename Chromeo)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:8080, CTRL+C to stop
```

Rackup will prefer better servers like Thin over WeBrick. There's
nothing super fancy going on here. The code inside `config.ru` is
evaluated and built using a `Rack::Builder` which generates an API
compliant object. The object is passed to the rack server (Thin) in
this case. Thin puts the app online.

## Rails & Rack

Rails 3+ is a fully Rack compliant. A Rails 3 application is more
complex Rack app. It has a complex middleware stack. The dispatcher
is the final middlware. The dispatcher reads the routing table and
calls the correct controller and method. Here's the stock middleware
stack used in production:

```
use Rack::Cache
use ActionDispatch::Static
use Rack::Lock
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x007fce77f21690>
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use ActionDispatch::DebugExceptions
use ActionDispatch::RemoteIp
use ActionDispatch::Callbacks
use ActiveRecord::ConnectionAdapters::ConnectionManagement
use ActiveRecord::QueryCache
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ParamsParser
use ActionDispatch::Head
use Rack::ConditionalGet
use Rack::ETag
use ActionDispatch::BestStandardsSupport
run YourApp::Application.routes
```

The middlewares are not declared explicitly in `config.ru`. Rails
applications create their own middleware chains from different
configuration files. The application instance delegates `call` to the
middleware chain. Here's an example `config.ru` for a rails app:

```ruby
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Example::Application
```

You know that `Example::Application` must have a `call` method.
Here's the implementation of this method from 3.2 stable:

```ruby
# Rails::Application, Rails::Application < Rails::Engine
def call(env)
  env["ORIGINAL_FULLPATH"] = build_original_fullpath(env)
  super(env)
end

# Rails::Engine
# the super class method
def call(env)
  app.call(env.merge!(env_config))
end

# app method in the super class
def app
  @app ||= begin
    config.middleware = config.middleware.merge_into(default_middleware_stack)
    config.middleware.build(endpoint)
  end
end
```
