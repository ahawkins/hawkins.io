---
layout: post
title: Handling Legacy APIs
tags: [rails]
---

Well, it's been a while since I've written a post to my blog. I'm on a
plane back to Helsinki for some intense work. I've got some trance on so
I figure I'll scratch and itch and try to get something written.

There are few things poeple never mention when they are teaching rails
to rookies, or hell, really even talk about in general. Rails gets a lot
of play for how easy it is to write RESTful APIs. It deserves it.
However, no one ever mentions what it _actually means_ to write a web
API. I haven't see anyone talk about freezing input formats or output
formats. The common approach is to just throw in `respond_to :json` then
go on your merry way. It works, but it's got some problems.

## Dealing with Changes

Let's first examine the most basic and widely adverised Rails RESTful
API controlller.

    class FoosController < ApplicationController
      respond_to :json

      def new
        respond_with Foo.create(params[:foo])
      end

      def show
        respond_with Foo.find params[:id]
      end

      def index
        respond_with Foo.all
      end

      def update
        foo = Foo.find params[:id]

        respond_with foo.update_attributes(params[:foo])
      end

      def destroy
        foo = Foo.find params[:id]

        respond_with foo.destroy
      end
    end

**Zomg!** You have an API! Well, no. You've just defined a simple
webservice that communicates with JSON. You have not met the two
fundamental requirements for writing an API:

1. Input parameters stay the same forever for a given API version
2. Output formats stay the same forever for a given API version.

Let's say you change an attribute on the `Foo` class. You'll likely be
smacked with a lof of `UnknownAttribute` errors. Then on the other end,
there previous parameter will be renamed in the outputted JSON.
Congratulations, you've just made an API that has Facebook consistency.
As the developer, you need to take steps to ensure that you're API stays
to the standards you've written. 

You have two ways to handle this problem. You can build logic into the
underlying model to handle deprecated methods. You could code some logic
into the controller to convert legacy input parameters. You could write
a middleware that will handle some changes. There are a few ways to
tackel this problem. I'll share how I did it for Radium.

## Handling Legacy API Input Parameters

A long time ago. I wrote a webservice for a Symbian (kill it with fire)
application. The API was supposed to exist for maybe a few months for
prototyping. Turns out it's taken over 1.5 years to develop (and it's
not done yet) the application. In that time, my simple API interface to
some common models has had to stay the same. You can imagine over the
course of 1.5 years the underyling schema and model layer will undergo
changes. For examples, one record use to a series to timestamps and a
state machine to track it's progress. Now there is a simple boolean
flag. Attributes have been renamed. Classes have changed. The
underlying data model has matured but the API hadn't. Now I'm facing a
problem with supporting legacy input parameters and legacy output
formats. I was using the wonderful `to_json` method. 

I needed to take different param hashes, change values, rename keys, and
some various other massaging to fit current model. So I decided to write
a class for each different type of API call. There are todos, contacts,
and meetings. Here is a snippet of one of the classes:

    module SymbianAPI
      class LegacyTodoConverter
        def self.convert(params)
          params[:finished] = true if params.delete(:finished_at)
          params[:description] = params.delete :task
          params[:finish_by] = params.delete :due_at

          # more stuff

          params
        end
      end
    end

I ended up writing 3 of these type's of classes. They massage the legacy
params for the API request and update them to fit the current model.

I took a more complicated route implementing them. I wanted my
controllers to look as vanilla as possible. I didn't want to have to
reference these classes in every request or write a `before_filter`. I
just wanted the controller to know that `params[:foo]` is good to go. I
dedecied to write a middleware that would automatically convert the
legacy parameters based on the route. So if the route mataches
`/api/customers`, then I would use my LegacyCustomerConvertor to merge
in the new params. There is some other trickery going on here, but I
figure I'd share the code for anyone who is interested.

    class SymbianApiAdapter
      def initialize(app)
        @app = app
      end

      def call(env)
        if request_for_symbian_api?(env)
          @app.call convert_legacy_input(env)
        else
          @app.call env
        end
      end

      private 
      def request_for_symbian_api?(env)
        parts = env['PATH_INFO'].split('/')
        parts[1] == 'api' && parts[2] != 'v2'
      end

      def convert_legacy_input(env)
        # No fucking clue why we have to do this trickery for PUTS
        if env['REQUEST_METHOD'] == 'PUT'
          params = Rack::Request.new(env).POST
        else
          params = env['rack.request.form_hash']
        end

        if params.present? && params['xml'].present?
          adapter = case env['PATH_INFO']
                    when '/api/todos/sync'
                      Api::Adapters::TodosAdapter
                    when /todo/
                      Api::Adapters::TodoAdapter
                    when '/api/meetings/sync'
                      Api::Adapters::MeetingsAdapter
                    when /meeting/
                      Api::Adapters::MeetingAdapter
                    when '/api/customers/sync'
                      Api::Adapters::CustomersAdapter
                    when /customer/
                      Api::Adapters::CustomerAdapter
                    end

          env['rack.request.form_hash'] || {}

          if adapter
            xml = params.delete 'xml'
            hash = Hash.from_xml(xml)

            if hash.values.first.is_a?(Hash)
              converted_params = {}
              converted_params[hash.keys.first] = adapter.convert(hash.values.first.with_indifferent_access)
              env['rack.request.form_hash'].merge! converted_params
            elsif hash.values.first.is_a?(Array)
              env['rack.request.form_hash'].merge! adapter.convert(hash)
            end
          end
        end

        env
      end
    end

This keeps my controllers small since they don't have to worry about
handling the paramters. They are just correct when the request finally
hits the controller. Now there is also a wall between what comes in
from the request and what actually hits the models. This makes it much
easier to **ensure future support**. All I need to do is update those
convertor classes and things will continue. Now at this point I can
write this controller action and never worry about the params.

    class FoosController < ApplicationController
      respond_to :json

      def create
        reapond_with Foo.create(params[:foo])
      end
    end

## Handling Legacy API Output Formats

There has finally been some talk about this sort of thing. There needs
to be a way to easily generate different blocks of JSON depending on
what API version is in use--essentially different **views**.
There are a few ways to do this. You could use a fancy new JSON 
builder like Rabl. I have not used Rabl. I investigated it, but I 
find that using builders in views is cumbersom when you need to write
some code. (And code doesn't belong the view anyway). I opted for an
easier approach. (And given that this is currently a Rails 2 app, there
are no other options). I wrote another three classes that take the
record to be returned and generate an output hash. That hash can then be
used for `to_json` or `to_xml`. Here's how they work.

    module Api
      class LegacyContactAdapter
        def self.convert(contact)
         {
          :town => contact.city, # API was specified to return a 'town' attribute
          :postcode => contact.zip_code # API specificed a 'postcode' attribute

          # so on and so forth. Build up the hash with the specified
          # attributes
        }
      end
    end

Now, the controller can use that class to return the required JSON. 

    def create
      foo = Foo.create params[:foo]

      if foo.save
        respond_to do |wants|
          wants.json { render :json => Api::LegacyContactAdapter.convert(contact), :status => :created }
        end
      else
        respond_to do |wants|
          wants.json { render :json => contact.errors, :status => :unprocessable_entity }
        end
      end

Using that classes ensure that it's easy(ier) to support the legacy API
into the future because there is a wall in the code. Also, if the
contact model ever changes, or the api needs a new output paramter, you
can just throw it into the various `Adapter` classes.

## Wrapping it Up

Writing API's is serious business. They represent a contact between your
system and external developers. You need to do everything in your power
to ensure that you hold up your end of the baragin. You need to ensure
that the input parameters are always accepted and that you stick to the
given output format no matter what changes. I've showed you some
different ways you can hold up your end of the contract. A middleware
based solution may not work in every situation. I could've easily used a
`before_filter` but I didn't like that. The important thing is to build
walls between the API and the other parts of your code that way it's
easier to ensure support in the future.
