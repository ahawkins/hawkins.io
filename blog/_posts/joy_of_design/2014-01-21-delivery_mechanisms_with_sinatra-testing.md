---
title: "Delivery Mechanisms with Sinatra - Testing"
layout: redirect
redirect: "https://www.joyofdesign.info/2014/delivery-mechanisms/testing/"
---

It's time for the final post on delivery mechanisms. This one is all
about testing--the who, what, and why. Testing is arguably a
developer's most important responsibilities. The goal is to ensure
that the applications works correctly. Testing delivery mechanisms
means testing the user facing applications. The delivery mechanism has
one fundamental goal: provide access to your domain objects in a given
medium. The medium may be JSON over HTTP or a complicated UI
composed with HTML and CSS. Either way each must be tested
accordingly. Testing HTTP delivery mechanisms can range from simple
and straight forward to quite complex. Luckily for us we can test in
an easy functional way because the interaction is just JSON.

## Testing JSON Endpoints with Rack::Test

`rack-test` is a wonderful gem. It provides the perfect abstraction
for testing rack applications. The gem includes `post`, `put`,
`delete`, `get`, `options`, and `patch` helpers for making
requests. It is also extremely fast. Delivery mechanism tests should
cover the following points:

* Does the server return the correct status code for the given
  operation?
* Does the server return the correct JSON object?
* Does the server handle a malformed request correctly?
* Does the server handle unauthenticated requests correctly?
* Does the server handle use case failures correctly?

Notice that the tests do no include anything related to the use cases
themselves. The test send real data and work with real objects. Let's
start at the very beginning with a happy path test.

```ruby
require 'rack/test'

class JsonServerTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    JsonServer
  end

  def test_returns_a_201_when_uploading_a_new_photo
    post '/photos', photo: { valid: 'params' }

    assert_equal 201, last_response.status
  end
end
```

The test is straight forward. The rack test helpers expect an `app`
method to exist. That is defined to return the Sinatra app. Next just
start making requests. `last_response` is provided by
`Rack::Test::Methods`. This test covers the bare minimum happy path.

The server should also return JSON. Let's test that.

```ruby
def test_returns_photo_json_when_uploading_a_new_photo
  post '/photos', photo: { valid: 'params' }

  assert_equal 201, last_response.status
  assert_includes last_response.content_type, 'application/json'

  json = JSON.parse(last_response.body).fetch('photo')
  assert_kind_of Hash, json
  assert json.fetch('id')
end
```

This test sends the same request then asserts on the response. Note
`assert_includes` instead of `assert_equal`. Sinatra's `json` helper
returns `application/json;utf-8`. Instead of worrying about encoding, I
only focus on the content type itself. Next the JSON is parsed (parse
errors will make the test fail), then `fetch` is used to ensure the
JSON contains the proper root key. Next test that it returns an object
that contains an `id` key.

You may be thinking: where are the test for all the other attributes?
Surely there is more data than just the ID. It's not worth it to test
every single bit of JSON. I use `ActiveModel::Serializers` to generate
JSON. Pretty much all of the code is declared with class level macros.
I don't see the need to test that they work (How often do you write
tests for a library?). However, if I have written custom logic about
what should be included or if associations should be given as objects
or ids on a request by request basis then I do test that. I do some
testing on the JSON response. I do not test the values, but mainly
that the keys are there and of the right type. I usually do these
sorts of things in the "read object" route. Here's an example.

```ruby
def test_returns_photo_json_of_the_requested_photo
  get "/photos/#{photo.id}"

  assert_equal 200, last_response.status
  assert_includes last_response.content_type, 'application/json'

  json = JSON.parse(last_response.body).fetch('photo')
  assert_kind_of Hash, json
  assert json.fetch('id')

  # Test all the general things are there
  assert json.fetch('url')

  # Always test that times are in UTC IS8601
  assert_iso8601 json.fetch('date')

  # Test that associations are given
  assert_kind_of Array, json.fetch('comments')
  assert_kind_of Hash, json.fetch('user')
end
```

That sums up all there is cover on testing individual endpoints.

## Unit Testing Sinatra Applications

The application will have global error handlers that need to be tested
as well. These are not specific to any route so testing can be
confusing. How do you trigger these errors? Well define a route that
simply raises the error. Each test can subclass the Sinatra app and
declare a test route that raises the appropriate error. Then assert on
the response.

```ruby
require_relative 'test_helper'

class WebServiceTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  attr_reader :app

  def test_form_errors_return_400
    @app = Class.new Chassis::WebService do
      get '/' do
        raise Chassis::Form::UnknownFieldError, :test
      end
    end

    get '/'

    assert_equal 400, last_response.status
    assert_json last_response
    assert_error_message last_response
  end
end
```

## Real World Code

The first example was pure fiction. The unit testing example was taken
directly from the chassis source code. Testing is very difficult
learn. The only way to get better at testing is to read and
write a ton of tests. In that vain I offer this complete test file
from my latest iOS backend.

<script src="https://gist.github.com/ahawkins/1cbc091a8174ec19d69d.js"></script>

## That's All Folks

This is the final post on delivery Mechanisms. I've covered their
complete responsibility sphere middleware, helpers, error handling,
domain object interaction, logic-less views, and finally testing. JSON
delivery mechanisms can be quite small. If you look at the tests and
previous posts you'll see that they don't really do much but they
exist as a powerful boundary between the world and the code.

Now that delivery mechanisms have been beaten to death, time to move
into the domain area! The next post is on writing [form
objects](/2014/01/form_objects_with_virtus/) with
Virtus.
