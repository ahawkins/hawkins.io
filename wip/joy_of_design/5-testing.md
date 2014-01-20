---
title: "Delivery Mechanisms with Sinatra - Testing"
layout: post
---

It's time for the final post on delivery mechanisms. This one is all
about testing--the who, what, and why. Testing is arguably a
developer's most important responsibilities. It's our job to ensure
that our applications work correctly. Testing delivery mechanisms
means testing the user facing application. The delivery mechanism has
one fundamental goal: provide access to your domain objects in a given
access medium. The medium maybe JSON over HTTP or a complicated UI
composed with HTML and CSS. Either way each must be tested
accordingly.

## Testing JSON Endpoints with Rack::Test

`rack-test` is a wonderful gem. It provides the perfect abstraction
for testing rack applications. The gem gives include `post`, `put`,
`delete`, `get`, `options`, and `patch` helpers for making requests to
a rack application. It is also extremely fast. The tests delivery
mechanism tests are very straight forward. They cover these cases:

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
method to exist. That is defined to return the sinatra app. Next just
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

This test sends the same requests then tests the response. Note
`assert_includes` instead of `assert_equal`. Sinatra's `json` helper
returns `application/json;utf-8`. Intead of working about encoding, I
only focus on the content type itself. Next the JSON is parsed (parse
errors will make the test fail) then `fetch` is used to ensure the
JSON contains the proper root key. Next test that it returns an object
that contains an `id` key. I think that's enough. 

It's not worth it to test every single bit of JSON. I use
`ActiveModel::Serializers` to generate JSON. Pretty much all of the
code is declared with class level macros. I don't see the need to test
that they work. However, if I have writing some custom logic about
what should be included or is objects should be embedded or as ids
then I do test that. I usually do these sorts of things in the "read
object" route. Here's an example.

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
as well. These are not specific to any practicular route so testing
can be confusing. How do you trigger these errors? Well define a route
that simply raises the error. Each test can subclass the sinatra app
with a test route that raises the appropriate error. Then assert on
the response.

```ruby
require_relative 'test_helper'

class WebServiceTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  attr_reader :app

  def setup
    @app = Chassis::WebService
  end

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

The first example was made up. The unit testing example was taken
directly from the chassis source code. Testing is a very difficult
thing to learn. The only way to get better at testing is to read and
write a ton of test cases. In that vain I bare myself before with a
complete acceptance test case from an IOS backend I wrote.

```ruby
require_relative '../../test_helper'

class CreateUserTest < AcceptanceTestCase
  def test_uses_the_auth_code_to_create_a_user
    post '/user_token', user_token: { phone_number: "+19253736317" }
    assert_equal 202, last_response.status

    refute_empty sms.messages
    message = sms.messages.first
    assert_equal '+19253736317', message.number
    assert message.text, "SMS must contain the auth code"

    refute_empty AuthTokenRepo

    post '/users', user: {
      name: 'Adam',
      auth_token: message.text,
      device: {
        uuid: 'some-uuid',
        push_token: 'some-token'
      }
    }

    assert_equal 201, last_response.status

    assert_equal 1, UserRepo.count
    db = UserRepo.first

    assert_equal 'Adam', db.name
    assert_equal '+19253736317', db.phone_number

    assert_equal 'some-uuid', db.device.uuid
    assert_equal 'some-token', db.device.push_token

    assert_empty AuthTokenRepo, "Auth token should be deleted after use"
  end

  def test_returns_the_user_as_json
    post '/user_token', user_token: { phone_number: "+19253736317" }
    assert_equal 202, last_response.status

    refute_empty sms.messages
    message = sms.messages.first
    assert_equal '+19253736317', message.number
    assert message.text, "SMS must contain the auth code"

    post '/users', user: {
      name: 'Adam',
      auth_token: message.text,
      device: {
        uuid: 'some-uuid',
        push_token: 'some-token'
      }
    }

    assert_equal 201, last_response.status
    assert_includes last_response.content_type, 'application/json'

    json = JSON.load(last_response.body).fetch('user')

    assert_kind_of String, json.fetch('id')
    assert json.fetch('name')
    assert json.fetch('token')

    json = json.fetch('device')

    assert json.fetch('uuid')
    assert json.fetch('push_token')
  end

  def test_returns_400_if_user_token_is_missing
    post '/user_token', user_token: nil
    assert_equal 400, last_response.status

    post '/user_token'
    assert_equal 400, last_response.status
  end

  def test_returns_422_if_phone_number_is_invalid
    post '/user_token', user_token: { phone_number: nil }
    assert_equal 422, last_response.status

    post '/user_token', user_token: { phone_number: '' }
    assert_equal 422, last_response.status

    post '/user_token', user_token: { phone_number: '3282314' }
    assert_equal 422, last_response.status
  end

  def test_returns_a_403_if_auth_code_is_bad
    assert_empty AuthTokenRepo

    post '/users', user: {
      name: 'Adam',
      auth_token: 'foo',
      device: {
        uuid: 'some-uuid',
        push_token: 'some-token'
      }
    }

    assert_equal 403, last_response.status
  end

  def test_returns_422_when_auth_token_is_blank
    post '/users', user: {
      name: 'Adam',
      auth_token: nil,
      device: {
        uuid: 'some-uuid',
        push_token: 'some-token'
      }
    }

    assert_equal 422, last_response.status
  end

  def test_returns_422_when_name_is_blank
    post '/users', user: {
      name: nil,
      auth_token: 'foo',
      device: {
        uuid: 'some-uuid',
        push_token: 'some-token'
      }
    }

    assert_equal 422, last_response.status
  end

  def test_raises_an_error_if_device_information_is_missing
    post '/user_token', user_token: { phone_number: "+19253736317" }
    assert_equal 202, last_response.status

    refute_empty sms.messages
    message = sms.messages.first
    assert_equal '+19253736317', message.number
    assert message.text, "SMS must contain the auth code"

    post '/users', user: {
      name: 'Adam',
      auth_token: message.text
    }

    assert_equal 422, last_response.status
  end

  def test_raises_an_error_if_device_id_is_invalid
    post '/user_token', user_token: { phone_number: "+19253736317" }
    assert_equal 202, last_response.status

    refute_empty sms.messages
    message = sms.messages.first
    assert_equal '+19253736317', message.number
    assert message.text, "SMS must contain the auth code"

    post '/users', user: {
      name: 'Adam',
      auth_token: message.text,
      device: {
        uuid: nil
      }
    }

    assert_equal 422, last_response.status

    post '/users', user: {
      name: 'Adam',
      auth_token: message.text,
      device: {
        uuid: ''
      }
    }

    assert_equal 422, last_response.status
  end

  def test_has_backstage_route_to_shortcuit_auth
    post '/backstage/users', user: {
      name: 'Adam'
    }

    assert_equal 201, last_response.status

    assert_equal 1, UserRepo.count
    db = UserRepo.first

    assert_equal 'Adam', db.name
    assert db.phone_number

    assert db.device.uuid
    refute db.device.push_token

    assert_empty AuthTokenRepo, "Auth token should be deleted after use"
  end
end
```
