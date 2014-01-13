---
title: Rediscovering the Joy of Design Part 1: Delivery Mechanisms
layout: post
---

Welcome to the first post in my "Rediscovering the Joy of Design"
series. The first part revolves around HTTP delivery mechanism using
Sinatra. What is a delivery mechanism? A delivery mechanism sits
between access medium and the domain code. Here are some examples. The
[thor](http://github.com/erikhuda/thor) is a delivery mechanism for
CLI applications. [Sinatra](http://github.com/sinatra/sinatra) is a
deivery mechanism for HTTP. The access medium may be machine or for
humans. It doesn't make a difference. It is the thing that makes the
application available to users. Here are some delivery mechanism responsiblies:

* Maintain state needed to communicate to domain objects
* Handle domain errors in a medium apporiate way (pring to `STDERR` or
  display a JavaSript `alert()`.
* Construct form objects required by use cases
* Respond medium apporiate representation of domain objects (HTML,
  JSON, or a table on `STDOUT`)

I write all my web delivery mechanisms with Sinatra. There are no
exceptions. Sinatra is so light weight and flexible--and it shows.
You can compose applications from other Sinatra applications, throw
middlware all over the place, use factories to build new Sinatra apps,
and you pretty much do whatever you want with it. It's so mallable. It
also has no major dependencies which is **extremely** important.
Choosing a tool is important. How you use it is more important.

Sinatra is the outer boundary between the domain and outside world.
The web app only deals with HTTP (delivery mechanism concerns),
instantiating the correct classes and calling them. It takes the
result and serializes it to JSON and that's a wrap. A rack request
starts with middleware. I'll start there.

## Middleware

A middleware stack is a mighty powerful abstraction. A middleware can
do so many things. A middleware is a piece of code that sits between
the request acceptor (server) and the final handler. You can get up to
speed on rack and middleware following this
[guide](/2012/07/rack_from_the_beginning/). I started to embrace
middleware after moving away from Rails and learnig more about pure
Rack. Rack's interface is the simplest one I'ver ever seen. It's also
powerful. I started to push more and more logic into middleware to
keep the final route handler as clean as possible. I'll cover some
examples of that later. First, I want to cover my default stack.

My default stack represents all the shared functionality I've
encountered from developing many different web services. They are
pulled from multiple sources and simply handled rolled. Here's the
stack.

* `Rack::BounceFavicon` - No Favicon (`rack-contrib`)
* `Rack::PostBodyContentTypeParser` - Parse JSON bodies
  (`rack-contrib`)
* `Rack::ConditionalGet` - 302 Not Modified support (`rack`)
* `Rack::Cache` - Full HTTP caching support (Varnish prefered if
  possible) (`rack-cache`)
* `Rack::Deflator` - GZipping (`rack`)
* `Manifold::Middleware` - CORS (`manifold`)
* `Harness::RackInstrumenter` - Performance Tracking `(harness-rack)`

This satisifies my bare minium use case: caching, JSON parsing, CORS
(if writing browser consumer), and gzip handling. Each application
customizes the stack from there.

## Middleware Use Cases

I've done a lot of cool stuff in middleware. It's very handy when it
contains the right logic. Here are some examples.

User's commonly authenticate to web services with tokens. This
authentication strategy can be presented in a middleware. Now the
power comes. Since it is a middleware it can be swapped out for
something else. In the tests I swapped this middleware for a fake
implementation that simply returned the user passed in the
constructor. I also used the same middleware to "short circuit" the
application in development so I can develop the frontend without
having to worry about authentication in the beginning. Here's the
code:

```ruby
class WebService < Sinatra::Base
  class TokenAuth
    def initialize(app)
      app = @app
    end

    def call(env)
      # Get the 'X-User-Token' header
      token = env.fetch HTTP_X_USER_TOKEN' do
        raise "Auth header missing!"
      end

      env['app.current_user'] = UserRepo.user_with_token! token

      @app.call env
    end
  end

  class FakeAuth
    def initialize(app, user)
      @app, @user = app, user
    end

    def call(env)
      env['app.current_user'] = user
      @app.call env
    end
  end

  helpers do
    def current_user
      env.fetch 'app.current_user' do
        raise "no current user"
      end
    end
  end
end
```

Voilla, completely swappable authentication strategies. The final
application is independent from how `app.current_user` is set. It just
needs it to be.

Middleware is also a great place to handle client specific things. I
worked on an ember application that had some really _interesting_ JSON
structure rules. It does not make sense to build these into the
application itself since they were specific to a given client. The web
service needed to take the provided data (ember data specific) make it
domain specific then take domain specific output and convert it into a
format ember data could understand. This was beneficial because I
could simply pass requests/responses to the middlware in tests and
see what happend. I did not have to involve any other objects. Here's
a rough outline of what one of these classes looked like. There were
roughly 15. There was one for each resource.

```ruby
require 'rack/request'
require 'json'

class EmberDataTodoSupport
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new env

    if ember? request
      # Convert stuff going in
      params['todo'] = convert_todo(req)

      [status, headers, body] = @app.call env

      json = JSON.parse body

      # Rack will calculate the correct value
      # incorrect values will break clients
      headers.delete 'Content-Length'

      [status, headers, convert_output(json)]
    else
      @app.call env
    end

    private
    def ember?(req)
      request.env['HTTP_X_EMBER_DATA_VESION'] == '0.13'
    end

    def convert_todo(req)
      # manipulate params here
    end

    def conver_response(json)
      # manipulate output here
    end
  end
end
```

These middleware grew to contain a lot of logic over time. That was
completely ok since they were isolated and testable.

Middleware are also great for performance monitoring.

```ruby
class RequestPerformance
  def initialize(app, statsd)
    @app, @statsd = app, statsd
  end

  def call(env)
    @statsd.time do
      @app.call env
    end
  end
end
```

That handy middleware will put all requests through a statsd timer.
This is exactly how
[harness-rack](https://github.com/ahawkins/harness-rack) works. That
middleware is included in my default stack.

Running applications on AWS is interesting. Occasionally the IP will
get reused sending all sorts of unwanted requests your way. I wrote a
bouncer middleware for exactly this purpose. It takes a block. If the
block returns true the request is denied. The middleware is simple.

```class
class RequestBouncer
  def initialize(app, bouncer)
    @app, @bouncer = app, bouncer
  end

  def call(env)
    req = Rack::Request.new env
    if bouncer.call req
      [403, { }, []]
    else
      @app.call env
    end
  end
end

class NightClub < Sinatra::Base
  use RequestBouncer do |req|
    req.user_agent =~ /masscan/
  end
end
```

This is nice when you discover werid traffic patterns. Insert at top
of stack.

One final example. I also setup status/health checks in middleware.
These are required when running application servers behind something
like an ELB or HAProxy. If an application fails the status check then
it should killed so a new process should start. This happens in two
separate middlewares. There is a checker which defines the route and
executes some code. The second catches any possible exceptions and
terminates the process. They are separate because you don't want
errors in tests to kill the process. Separting also lets you play
around with the most effective health check in development.

```ruby
HealthCheckError = Class.new RuntimeError

class StatusCheck
  def initialize(app, check = nil)
    @app, @check = app, check
  end

  def call(env)
    if env['PATH_INFO'] == '/status'
     if @check
        begin
          result = @block.call(::Rack::Request.new(env))
          raise "health check did not return correctly" unless result
        rescue => boom
          fail HealthCheckError, boom.to_s
        end

        [200, {'Content-Type' => 'text/plain'}, ['Goliath Online!']] 
      end
    else
      @app.call env
    end
  end
end

class Executioner
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call env
    rescue HealthCheckError => ex
      env['rack.errors'].write ex.to_s
      env['rack.errors'].write ex.backtrace.join("\n")
      env['rack.errors'].flush
      exit!
    end
  end
end
```

The status check middlware optionally takes a block. The block can be
used to test connections to external services (like a DB). This is
especially useful with MySQL since connections expire if not used
after a while. Constant pinging from the load balance will keep
everything open. Here's how to use it with Sinatra.

```ruby
class App < Sinatra::Base
  # Must be before StatusCheck is inserted
  configure :staging, :production do
    use Executioner
  end

  use StatusCheck do
    Sequel.db.connected? && App.redis.connected?
  end
end
```

I hope that demonstrates how you can use middleware effectively in an
application. Middleware is your friend. Become best friends.

## Helpers

I have a common set of helpers across all apps. They are: `serialize`,
`halt_with_error`, `json_error`, and `extract!`. `extract!` is first
because it involves the other helpers.

```ruby
class WebService < Sinatra::Base
  helpers do
    # Keep clients honest by forcing them to send the correct params
    def extract!(key)
      value = params.fetch(key.to_s) do
        raise ParameterMissingError, key
      end

      raise ParameterMissingError, key unless value.is_a?(Hash)

      value
    end
  end

  # raised by extract! used if POST /photos does not include a `photo`
  # key
  class ParameterMissingError < StandardError
    def initialize(key)
      @key = key
    end

    def to_s
      %Q{Request did not provide "#{@key}"}
    end
  end
end

Next up `json_error`. This helpers take an exception and status code
and reports a JSON representation.

```ruby
class WebService < Sinatra::Base
  helpers do
    def json_error(ex, code, errors = {})
      halt code, { 'Content-Type' => 'application/json' }, JSON.dump({
        message: ex.message
      }.merge(errors))
    end
  end
end
```

`halt_json_error` is entirely used by Sinatra's error handlers as
you'll see in a moment.

```ruby
class WebService < Sinatra::Base
  helpers do
    # Helper abort an request from an exception
    def halt_json_error(code, errors = {})
      json_error env.fetch('sinatra.error'), code, errors
    end
  end
end
```

`serializer` is the final helpers. It wraps `ActiveModel::Serializers`
interface.

```ruby
class WebService < Sinatra::Base
  helpers do
    # ActiveModel::Serializer helper
    def serialize(object, options = {})
      klass = options[:serializer] || object.active_model_serializer
      options[:scope] ||= nil
      serializer = klass.new(object, options)
      serializer.as_json
    end
  end
end
```

All those helpers really come together when handling errors and use
cases specific error codes.

### Error Handling

The previously described helpers make error handling easy. Here's an
example.

```ruby
class WebService < Sinatra::Base
  # global errors can be caught and return the same status code
  # globally
  error PermissionDeniedError do
    halt_json_error 403
  end

  # raised by exract!
  error ParameterMissingError do
    halt_with_json_error 400
  end
```

That covers the common error handling bits. Now for the final bit:
route handling!

### Route Handling

Like I mentioned before, the delivery mechanism is responsible for
constructing the from object and the required use case. It runs the
use case and returns the result apporiate to the medium. It also
captures use case specific failures and responds in the correct way.

I'll build one up from scratch (look out for the helpers).

Step 1: Instantiate the objects

```ruby
class WebService < Sinatra::Base
  post '/users' do
    # extract is used to ensure the client sends a proper "user" hash
    # so it can be passed to the form
    form = CreateUserForm.new extract!(:user)

    # Use cases always take forms. They make take other information
    # such as record ids or the current_user. This one does not.
    use_case = CreateUser.new form
  end
end
```

Step 2: Run the use case and save the result

```ruby
class WebService < Sinatra::Base
  post '/users' do
    form = CreateUserForm.new extract!(:user)
    use_case = CreateUser.new form

    # Run the use case
    user = use_case.run!

    # set proper status code
    status 201

    # Use a serializer to generate JSON
    # `json` is provided by `sinatra/json` in the sinatra-contrib gem
    json serialize(user, scope: user)
  end
end
```

Step 3: Capture & handle use case specific failures

```ruby
class WebService < Sinatra::Base
  post '/users' do
    begin
      form = CreateUserForm.new extract!(:user)
      use_case = CreateUser.new form

      user = use_case.run!

      status 201
      json serialize(user, scope: user)
    rescue CreateUser::UnknownAuthCodeError => ex
      # helper used to render out a given exception
      json_error ex, 403
    end
  end
end
```

All the route handlers follow the same structure. The handlers contain
no logic besides instantiating the objects, serializing, and reponse
code.

This sums up everything about using sinatra as JSON delivery
mechanism. This post has already gone on for too long! The next entry
will handle logicless HTML presentation. There is certainly a lot to
cover there! 

I'd love to pair with any of you implementing some of stuff in your
codebases. Get at me if you're interested. Until next time.
