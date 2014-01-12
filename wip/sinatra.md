I write all my web applications using Sinatra. There are no exception.
Sinatra is so light weight and flexible. Don't bring rails up in here.
Sinatra is pure rack. You can compose applications of other sinatra
applications, throw middlware all over the place, use factories to
build new sinatra apps, and you pretty much do whatever you want with
it. It's so mallable I'm absolutely in love with it. It also has no
major dependencies which is **extremely** important. Choosing a tool
is important. How you use it is more important.

Sinatra is the outer boundary between the domain and outside world.
The sinatra code only deals with HTTP (delivery mechanism concerns)
and instantiating the correct classes and calling them. It takes the
result and serializes it to JSON and that's a wrap.

I mentioned domain objects. There are the most important objects in
the application because they **are** the application! All the business
logic lives here. The web component only handles things relavant to
its delivery mechanism. Yay! Boundaries. So that's two boundaries so
far: the left and right of delivery mechanism. Use Cases and forms
live on the right. Any delivery mechanism can use these two objects to
actually do something. Each of these objects represents other
boundaries as well.

```ruby
class WebService < Sinatra::Base
  # Ain't no body got time for favicon.ico 
  use Rack::BounceFavicon

  # Turn on CORS 
  use Manifold::Middleware

  # Gizp
  use Rack::Deflater

  # JSON body parsing
  use Rack::PostBodyContentTypeParser

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

  helpers do
    # Keep clients honest by forcing them to send the correct params
    def extract!(key)
      value = params.fetch(key.to_s) do
        raise ParameterMissingError, key
      end

      raise ParameterMissingError, key unless value.is_a?(Hash)

      value
    end

    # Helper abort an request from an exception
    def halt_json_error(code, errors = {})
      json_error env.fetch('sinatra.error'), code, errors
    end

    def json_error(ex, code, errors = {})
      halt code, { 'Content-Type' => 'application/json' }, JSON.dump({
        message: ex.message
      }.merge(errors))
    end

    # ActiveModel::Serializer helper
    def serialize(object, options = {})
      klass = options[:serializer] || object.active_model_serializer
      options[:scope] ||= nil
      serializer = klass.new(object, options)
      serializer.as_json
    end
  end

  # Speicifc error classes get meaningful error codes
  error UserRepo::UnknownTokenError do
    halt_json_error 403
  end

  error Chassis::Repo::RecordNotFoundError do
    halt_json_error 404
  end

  # global errors can be caught and return the same status code
  # globally
  error PermissionDeniedError do
    halt_json_error 403
  end

  error AuthHeaderMissingError do
    halt_json_error 412
  end

  # What all the route handlers look like
  post '/users' do
    begin
      form = CreateUserForm.new extract!(:user)
      use_case = CreateUser.new form

      user = use_case.run!

      status 201
      json serialize(user, scope: user)
    rescue CreateUser::UnknownAuthCodeError => ex
      json_error ex, 403
    end
  end
end
```
