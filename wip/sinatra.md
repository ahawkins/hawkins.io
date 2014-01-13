

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
