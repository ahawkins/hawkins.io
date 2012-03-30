---
layout: post
title: "State of Writing API Servers with Rails"
tags: [rails, api]
---

We've been writing API's using Rails for a long time. It's nothing new.
However, making the API the sole and only reason to exist shifts your
application's purpose and architecture. This posts covers my experience
writing pure JSON APIs with Rails.

## Defining an "API Server"

This is what I consider a pure API server.

1. All responses are JSON
2. Authentication using some sort of tokens
3. `ActionView` is not present in the code base.
4. `Sprockets` is not present in the code base.
5. Some concept of versioning (inputs and outputs)

I think this covers a pretty basic Rails app.

## Existing Tries

There are already a few things that try to make writing a API with rails
easier. Basically they all just create less complicated version of
`ApplicationController::Base` and do some other basic stuff. 
[Strobe's Rails Extension](https://github.com/strobecorp/strobe-rails-ext) does this.
It's a basic solution, but not complete enough. There are a host of
similar solutions out there. Take a peak around if you like.

## Getting in the Door: Authentication

The primary method is using a token. The token is passed to the API
through headers (preferred) or standard parameter passing. Here
is the code I use to generate API keys in all my applications. 

    module HasApiToken
      extend ActiveSupport::Concern

      included do
        before_create :generate_api_key
      end

      private
      def generate_api_key
        self.api_key ||= Digest::SHA1.hexdigest(Time.now.to_s + attributes.inspect)
      end
    end

Then you can authenticate a request using the token like this:

    User.find_by_api_key!(request.headers['HTTP_X_API_TOKEN'] || params[:token])

Easy. I'm not sure if this pattern could be wrapped up in a gem because
it's very simple but it doesn't change much. Either way, this technique
gets the job done.

## Getting it Done: Generating JSON

Your API has return JSON. It's very surprising
to me that some solutions make this so damn complicated (I'm looking at
you JBuilder and Rabl). Returning JSON is a very simple process. You
only need to generate a Hash. This is done very easily via the
Presenter pattern. The presenter also needs to take the
`current_user` into account since different people get to see different
things. The presenter pattern is perfect because you can define a
different presenter class for each resource and even scope them under
different namespaces when you need to version things.

I use [ActiveModel::Serializers](https://github.com/josevalim/active_model_serializers)
because it's the perfect solution. It's very easy to define schemas and
test them independently of everything else. This is very important! It
seems to me that people forget this. OOP is good. Use it!

Here is an example serializer:

    class BlogPostSerializer < ActiveModel::Serializer
      attributes :title, :content, :posted_at

      has_many :comments

      def attributes
        hash = super

        # include secret if the user is an admin
        hash[:secret] = object.secret if user.admin?
        hash
      end
    end

You can test this very easily. Instantiate it with a blog post and user
and test that `as_json` returns the right stuff. No view layer. No
bullshit. Just classes following SRP. If you use Ember (which is
awesome), `ActiveModel::Serializers` will be be the default format for
the data store. Rails will automatically use the proper serializer when
using `respond_with` or `respond_to`.

I advise you to use ActiveModel::Serializers because it's a very simple
solution. You can easily define "partials" in modules that declare more
attributes. Unfortunately, there is only a 0.1.0 release out now. The
project is still under active development.

## Next Step: Parameter Santization and Authorization

[Strong Paramters](https://github.com/rails/strong_parameters) is a good
first step in moving authorization out of the model. I hope that dhh's
strong paramters is merged into Rails 4. It's a basic variation on
the slice pattern. It uses a method inside the controller to select the
valid parameters that can be sent to the model. 

Here is the important example from the readme:

    class PeopleController < ActionController::Base
      # This will raise an ActiveModel::ForbiddenAttributes exception because it's using mass assignment
      # without an explicit permit step.
      def create
        Person.create(params[:person])
      end

      # This will pass with flying colors as long as there's a person key in the parameters, otherwise
      # it'll raise a ActionController::MissingParameter exception, which will get caught by 
      # ActionController::Base and turned into that 400 Bad Request reply.
      def update
        redirect_to current_account.people.find(params[:id]).tap do |person|
          person.update_attributes!(person_params)
        end
      end

      private
        # Using a private method to encapsulate the permissible parameters is just a good pattern
        # since you'll be able to reuse the same permit list between create and update. Also, you
        # can specialize this method with per-user checking of permissible attributes.
        def person_params
          params.required(:person).permit(:name, :age)
        end
    end

I think that this is a step in the right direction, but I'd like to see
this logic moved into it's own class. StrongParameters doesn't consider
authorizations that may happen outside of a controller. It does make it
possible to extract the `person_params` method into it's own class. You
**should** do this.

## Action Authorization

There is only one thing to say:
[CanCan](https://github.com/ryanb/cancan). It is the best thing for
this. I think CanCan is almost perfect.

## Versioning

Enter the no-mans land. I still haven't found any that will handle
versioning in a clean way. I'm looking for something that builds
boundaries in my code. I'm looking for something that completely
separates the request input and request response. For example, say in
version API version 2, the parameters to `POST /foos` have changed. How
do you handle that? IMO, you need a class that can convert the message.
Same thing for output formats. How do you handle returning a different
format for version 2? You _could_ be a slacker and namespace routes
(`/api/v1/`, `/api/v2`). I don't think this is a good solution. The
version should be passed in the headers, not in the URI. It would be
perfect if I could find a gem that would take the Accept header and
automatically use `V2::Messages` and `V2::PostSerializer`. 

## Documentation

Documenting programs is hard. It is always hard no matter the context. I
think there are two different types of documentation. There is the exact
technical documentation. For example, this route takes this parameter.
This parameter must be this format or these values etc. These are return
values etc. Then there is the high level user guide type documentation.
Think the rails guides vs the API docs. You need both to create a
successful platform.

The major difference between them is that one is generated from
documentation in the code and the other is written by humans. At this
point it is infeasible that user guides can be generated
automatically. It is feasible that technical documentation can be
generated. Isn't the holy grail that you can change the code and have
the documentation updated? The big problem with documentation is that it
gets out of date because it's maintained in two separate places. What if
could solve that problem?

I think we can solve this problem. The first step, as with any code
documentation, is to define a standard format and where to put it. I
think you can put this code in the controller. Why the controller?
Because the controller is where your API meets the outside world. The
controller is what takes input and tells other classes to do stuff.
Also, the controller may do specific logic on parameters to sanitize
them or something else. The controller is the gatekeeper for your
application and the entry rules should be written on the gate. Now you
can combine this parameter declaration with parameter sanitization (ala
StrongParamters) and you'd really be onto something!

Here is an example from
[Rabbit](https://github.com/mifo/sinatra-rabbit). This doesn't do
everything that I'm talking about, but you'll see where I'm going:

    operation :show do
      description "Index operation description"
      param :id,  :string, :required
      param :r1,  :string, :optional, "Optional parameter"
      param :v1,  :string, :optional, [ 'test1', 'test2', 'test3' ], "Optional parameter"
      param :v2,  :string, :optional, "Optional parameter"
      control do
        "Hey #{params[:id]}"
      end
    end

At this point you could load the code and read the declarations.
Everything you need is there. You could write code to transform it into
[http://swagger.wordnik.com/](http://petstore.swagger.wordnik.com/).
How awesome would that be? This is
just an example of what can be done. The important part is updating the
code regenerates the documentation.

We still have to handle the user guide level documentation. I think
there are two ways to handle it. #1, you use something like [Tomdoc](http://tomdoc.org/) in
the controller for high level documentation. #2, you maintain it
separately. I've opted for #2 in my situation. I'm using my own code
here to write [api guides](https://github.com/threadedlabs/api_guides).
It's heavily inspired by Stripe's [docs](https://stripe.com/docs/api).
You can see an example [here](http://developer.radiumcrm.com).

Unfortunately, I haven't been able to solve the generated technical
documentation problem yet, but at least this is a start. 

I think there is a lot to be done on this front. If we as a community
can solve this problem, I think that crafting API's will be much easier
and more importantly, much faster.

## GET /going

I think there is still much work to be done on this front. I hope that
Rails 4 takes some of these ideas and folds them into the core. I know
that parameter authorization will be moved to the controller in Rails 4.
I hope they address the serialization problem as well (by not using
JBuilder). However, given DHH's love for it, I don't see that happening. 

I'd really like to see the community address the documentation problem.
I think there is a will too. It seems to me that more rails
developers are building simple applications and aren't really interested
in tackling the entire scope of the problem: How can build an HTTP API
in rails, maintain it, and release it to the public. At Radium, we are
building enterprise software. We think big. Working in this scope has
made me tackle many large problems. I hope that my experience will help
you as well.

When building an API, just remember: Rails is not your code. Your
application is separate. The controllers just talk to your code. Don't
get the two confused!

## Appendex

I've added this section to include links to things people have tweeted
me or showed me on IRC.

* [Grape](https://github.com/intridea/grape) - Github
* [Rabbit](https://github.com/mifo/sinatra-rabbit) - Github
* [Versionist](https://github.com/bploetz/versionist) - Github
* [Versioning RESTful APIs](http://freelancing-gods.com/posts/versioning_your_ap_is) - Blog Post
* [Hypermedia APIs](http://designinghypermediaapis.com/) - Book
* [Rails API Mode](https://github.com/rails/rails/commit/6db930cb5bbff9ad824590b5844e04768de240b1) - Reverted Commit for API mode for rails

## Sharing is Caring

Now in the vein of "Sharing is Caring", here is my base API controller
that I use:

<script src="https://gist.github.com/2237832.js?file=api_controller.rb"></script>
