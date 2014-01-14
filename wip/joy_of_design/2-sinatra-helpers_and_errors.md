---
title: "Delivery Mechanisms with Sinatra - Helpers & Errors"
layout: post
---

A delivery mechanism must act correctly for its medium. A HTTP
delivery mechanism must handle HTTP semantics. This mainly includes
handling the correct content type, accept, and status code. I have a
common set of helpers for this. They fulfill two
roles: extracting input parameters and serializing objects. These are
the common helpers between different applications. They
are: `serialize`, `halt_with_error`, `json_error`, and `extract!`.

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

`serializer` is the final helper. It wraps the `ActiveModel::Serializers`
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
cases specific exceptions.

The helpers make error handling easy. Here's an example.

```ruby
class WebService < Sinatra::Base
  # global errors can be caught and return the same status code
  error PermissionDeniedError do
    halt_json_error 403
  end

  # raised by exract!
  error ParameterMissingError do
    halt_with_json_error 400
  end
```

This post was short and sweet. All the helpers come together when
writing route handlers. Check back in a day or two for the next entry.
