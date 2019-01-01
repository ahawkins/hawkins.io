---
title: "Delivery Mechanisms with Sinatra - Route Handlers"
layout: redirect
redirect: "https://www.joyofdesign.info/2014/delivery-mechanisms/route-handlers/"
---

The delivery mechanism is responsible for instantiating the objects
required to complete a given interaction. The app constructs a form
object using input parameters. The form is passed to the use case. The
use case is run and returns an object. The delivery mechanism then
decides how properly respond for it's medium. It also captures use case
specific failures and responds in the correct way. For me this boils
down to: run the use case and serialize the result, or capture the
errors and respond with a correct status code and error message.

The route handlers use all the helpers so look at for them. You can
read about them in the previous post on [helpers &
error handling](/2014/01/delivery_mechanisms-helpers_and_error_handling/).

Time to move on to writing a route handler. Step 1: Instantiate the
objects.

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
no logic besides instantiating the objects, serializing, and status
code.

This sums up everything about using Sinatra as a HTTP (JSON) delivery
mechanism. The next entry will handle [logicless HTML
presentation](/2014/01/delivery_mechanisms_with_sinatra-logic-less_views/).
There is certainly a lot to cover there!

I'd love to pair with any of you implementing some of stuff in your
codebases. Get at me if you're interested. Until next time.
