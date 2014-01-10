---
title: Rediscovering the Joy of Design
layout: post
---

I've had an interesting last year and half or so. It has been a
transitionary time. I've learned so much and completely changed the
way I approach and think about software design, maintainability, and
implementation. The change has been so radical that I can sincerely
say that I could not got back. That path only leads to anger, anger
leads to hate, and hate leads to the dark side. This is a post about
going to the dark side in some way. In my opinion, my approaches are
controversial. They are controversial because so many Ruby programmers
have been spoon fed coupling and horrible programming choices since
they got into the language. I've shown people my techniques and have
been met with somewhat visercal reations: "What is this?", "Why are
they are so many classes?", "Why don't you just use \_insert gem
here\_?" These are honest questions but the reactions are like telling
a a dynamically typed evangelist that Haskell is the only _right_ way
forward. It's a shame that the design triggers these reactions. On the
other hand it's wonderful because something is working. People's ideas
are being challenged and they're begining to think about things in
different ways.

Undoubtably I am not the first person to learn these lessons. I'm sure
there are thousands of posts just like this. Maybe there are few
graybeards thinking "yes padowan. You have learned." That's ok. Some
lessons are best learned through first hand experience. You can read
about design patterns and boundaries until you're blue in the face but
you can never fully comprehend the pain they prevent until you've
spilled your blood over a code base. Sometimes you need to put in the
time before you can fully apperciate what design patterns are for.

I do web programming exclusively. I prefer to working on JSON API's
but I've also worked on (from what I can see the biggest Ember.js app)
[Radium CRM](http://radiumcrm.com). Since starting my new full time
job I've been doing server side stuff (which the extreme sadness of
writing user facing applications without Ember peppered around). This
gives you my past perspective to understand my current position.
Before this I was doing traditional rails app. I enjoyed it at the
time but when I started work exclusively on API's I realized this was
better. Why? The answer is simple.

Boundaries. All good design enforces the strict separation of concern
though boundaries. Boundaries are boxes and they encourage design
through protocols. What actually created the boundary? The internet
itself. When you design an JSON API you approach it from the client or
server side. There is only one thing: the data sent between each.
There is nothing else. This the only reason why the other side exists.
This was so liberating. In hindsight I think this started a ripple
effect in my thinking. From there everything changed. I began approach
every aspect of the application from a different perspective.

There is so much to say that I cannot be summed up clearly in one
post. I decided to approach this problem in a different medium. I took
my first stab at writing a technical "paper." I say paper loosely. The
paper itself should be professional, easy to read, on point, and
highly informative. It's clocking at about 20,000 words when it's all
said and done. I was lucky enough to recruit some people to review it.
Avdi Grimm was gracious enough to lend his time. Lucky for me because
I respect the shit out of that guy. One of his comments really stuck
with me:

> I haven't even reached the need for Repository and Query yet, and
> I've already experienced major design epiphanies. If there's a point
> to all this, it's this: consider not glossing over the building
> blocks that go underneath Repository. Not every app needs a
> repository (some don't even need Mapper). And every single layer of
> the cake, if approached mindfully and intentionally, can bring
> serious benefits.

Continously layering design patterns changes everything. It did for
me. This post is a summary of how I write my applications now. Every
point is covered in detail in the
[paper](https://github.com/ahawkins/hawkins.io/pull/7), but this is
quicker and more focused on specific use cases.

## Getting Things Done

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

Forms are border guards. All access to business logic goes through
forms. All the shit data coming from _where ever_ is transformed in
domain level Ruby objects. Form are objects are implemented with
Virtus. Virtus is another fantastic peice of software. It is
practically perfect of this use case. I can define custom
tranformations and convert hashes and god knows what else into my
domain classes. I also make these objects bitchy as hell. They are
bitchy for a reason. Anything that get's through them will never be
checked anywhere else in the entire subsystem so now foul ups here!
They are optimised for a few use cases. The most specific one is
grapping a blob of parameters and dumping them into an initializer.
They raise specific errors if an unknown parameter is given. They blow
up if a given value cannot be coerced. They do a few other things but
these are the most important. They ensure untrusted garbage input is
converted into the proper objects. This is the boundary between the
domain objects and the delivery mechanism.

Use cases take in a form and whatever external state (often the
current user) and do something. They are _use cases_. Use cases are
apporiately named: `CreateTodo`, `UploadPicture`, or `PostAd`. No REST
here! Domain use cases are isolated and agnostic. A use case has a
`run!` method (with varying signatures depending on context) and it
returns an object. Failures are communicate throw exceptions. I like
exceptions. I use exceptions much more often now. They sure prevent a
lot of weird stuff from happening. I usually have at least `ValidationError`
and `PermissionDeniedError`. I've never worked on app that didn't have
validations or some permissions. Each use case may raise its own
specific errors like `AccountCapacityExceededError` that only happen
when different objects are used in concert. I prefer this approach
because the containing delivery mechansim can capture the errors and
react accordingly. The errors are also very helpful in testing because
the classes describe the failure. This had made debugging random tests
so much easier because unexpected errors present themselves obviously.
How many times have written a test that fails in a werid way because
code assumed valid data? That happend a lot to me. It still happens,
but raising an error makes the root cause easy to diagnose.

Use cases are also fanastic because new use cases can simply be
composed of existing ones since they are isolated by design. I cannot
express how awesome this was when I saw it happen for the first time
in Radium. I had an existing use case: `CreateContact`. I had to write
a new use case: `SendEmail`. `SendEmail` was supposed to create new
contacts when it encountered unknown email addresses. At that moment I
realized I could simply instantiate a new `ContactForm` and
`CreateContact` use case and call them from inside `SendEmail`. It
worked perfectly the first time. I could never go back from that
moment. I actually consider it a defining moment in my software
development progression. I previously would've done that with a ton of
callbacks while violating a ton of boundaries and other sound design
principles. I cannot stress how imporant use cases are. The first time
you get to compose them it will be a mindly blowing moment. It was for
me.

Applications are nothing without data. Use cases interact with and
expose business objects. The only way for delivery mechanism to access
domain objects is through use cases. The only way use cases access
business objects is through a repository. This is the single most
important boundary you can have. There **must** be a strong separation
between the data and storage. Removing it promises pain. Using a
repository has honestly made me a happier programmer. I'll sum up the
most important parts in no practicular order.

* Having a boundary between objects and persistance allows each side
  to vary independently.
* The storage mechanism can be switched out with confidence (read: use
  memory in tests instead of a slower persistance mechanism)
* Every single data access goes through a single interface. This is
  great for caching and other optimizations
* All queries are made through a standard interface and into the
  repository. It is **impossible** for implementation details to leak
  into other parts of the applications.
* Easy to persist different models in use case speficic data stores.
  Need a simple key-value store? Implement part of the repoistory
  adapter using Redis. Other parts can be files, RDMS's or even as
  Uncle Bob puts it: "battery packed remoted controlled writing
  machines."
* Specific queries can be implemented in faster ways. Part of radium
  stores object graphs in views for ulimate speed. This is implemented
  using a separate code path for single object type queries and graph
  type queries. The semantics are all encapsulated in a single class.
  No details leak out.

Avid mentioned the repistory and query patterns. He said he had not
seen a use for them. I figured I'd fast forward a little. I went from
using _only_ ActiveRecord (and thusly the pattern itself) to
repository + query. The results have been wonderful. I was concerned
it would feel awkward in a smaller application. I'm pleased to say
that it doesn't. I do everything this way these days. It makes things
much better. Now that the repository has been beaten to death, it's
time to move onto business objects!

Business objects are plain old ruby classes with a bunch of
`attr_accessors`. They usually include modules for shared
functionality (but not so much). They are boring classes in a way
because the usually don't have so much logic. They encapsulate
business rules for their given state and some other stuff. Most
include the `Peristance` module. It declares an `id` `attr_accessor`
and a `save` method. The save method delegates to the correct
repository. This way I don't have calls to `XXXRepo` all over the code
when I simply want to persist a given business object.

The classes themselves are not so interesting. It's more interesting
how they are constructed and organized. In the past the models have
always represented presistance. This meant the DB's abstractions and
limitations leaked all over application. Now I just toss the object to
the repository and that handles it. I'm free to organize and construct
the domain objects in a way that makes sense for the specific use
cases--not the storage requirements. This has been a joy.
Unfortunately I cannot exmaine some examples of this without a lot of
ceremony and context. So you'll have to try it yourself for a while
and see what you think.

All of this makes writing tests suites much easier and faster. They
are faster beacuse every external communication happens through a
defined interface and boundary. Each boundary is swapped with an in
memory style implementation. The tests are also much faster because I
stay very mindful of what dependencies I bring into the project. If a
gem has more than two (generally) dependencies it doesn't make the
cut. The liberal use of exceptions make debugging tests easier as
well. Sinatra works perfectly with `rack-test`. It's dead easy to test
business logic: instantiate the use case and call `run!`. Boundary
specific things (like persistance implementations) happen in their own
tests. Instantiate the implementation, call the method, and asser the
result. I feel most confident in my code because it's easier to test
and thusly there are more test cases. I do all development & testing
using in memory implementations to flesh out the concepts and
interactions. There is usually a "ci" style test which uses the real
implementations. Example: I usually run the tests against the in
memory adapter, but CI will use the actual PostgreSQL implementation.
This keeps my tests fast and gives me confidence in production
environments. I use minitest because it is the best. I used to use
RSpec but what's the point? It doesn't add anything significantly
useful. I do concede one point: the failure messages are easier to
understand in some scenarios. But I don't think it's worth it to bring
in another dependency for "nice to haves." MiniTest is pure ruby and
comes in the standard library. Win-Win. I also find myself mocking and
stubbing a lot less. I think this a big win because I don't end up
with tests that rely to much on whitebox implementations. I can simply
stick a different black box on the end and see what the other side
does. This gives me more confidence in the code.

That bunch of rambling paragraphs sums up the big stuff in the
abstract. Let's look at some code.

## Show Me The Code

Let's start from the outside in, starting first with sinatra. Here's
what all my sinatra applications have in common.

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

A pretty good example use case:

```ruby
class AddPicture
  attr_reader :group_id, :form, :current_user

  def initialize(group_id, form, current_user)
    @group_id, @form, @current_user = group_id, form, current_user
  end

  def run!
    group = GroupRepo.find group_id

    authorize! group

    cloud = ImageService.upload form.file

    picture = Picture.new do |picture|
      picture.user = current_user

      picture.bytes = form.file.bytes

      picture.date = Time.now.utc

      picture.full_size_url = cloud.full_size_url
      picture.thumbnail_url = cloud.thumbnail_url
      picture.id = cloud.id

      picture.width = cloud.width
      picture.height = cloud.height
    end

    group.cover = picture if group.pictures.empty?

    group.pictures << picture

    group.save

    group.users.each do |recipient|
      next if recipient == current_user
      PushService.push(NewPicturePushNotification.new(picture, recipient))
    end

    picture
  end

  def authorize!(group)
    if !group.member? current_user
      raise PermissionDeniedError, "Only group members can add pictures"
    end
  end
end
```

Here's an example form:

```ruby
class CreateUserForm < Form
  attribute :name, String
  attribute :auth_token, String
  attribute :device, Hash

  validates :name, :auth_token, :device, presence: true

  validate do |form|
    next unless form.device

    uuid = form.device.fetch 'uuid', nil
    errors.add :device, "uuid cannot be blank" if uuid.blank?
  end
end
```

Here's a more complex one that demonstrates virtu's conversions:

```ruby
class PictureForm < Form
  class ImageUpload < Virtus::Attribute
    class MultipartImageUpload
      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def bytes
        tempfile.size
      end

      private
      def tempfile
        hash.fetch :tempfile
      end
    end

    def coerce(value)
      if value.is_a?(::Hash)
        MultipartImageUpload.new value
      end
    end
  end

  attribute :file, ImageUpload
end
```

Here's a model:

```ruby
class Group
  include Persistance
  include Serialization
  include Chassis::HashInitializer

  attr_accessor :name, :admin, :users, :pictures
  attr_accessor :cover
  attr_accessor :created_at, :updated_at

  def initialize(*args, &block)
    super
    @pictures ||= []
  end

  def save
    self.created_at = Time.now.utc if new_record?
    self.updated_at = Time.now.utc
    super
  end

  def total_pictures
    pictures.size
  end

  def member?(user)
    users.include? user
  end
end
```

Here is the persistance module:

```ruby
module Persistance
  extend ActiveSupport::Concern

  included do
    attr_accessor :id
  end

  module ClassMethods
    def create(*args, &block)
      record = new(*args, &block)
      record.save
      record
    end

    def repo
      @repo ||= "#{name}Repo".constantize
    end
  end

  def save
    repo.save self
  end

  def destroy
    repo.delete self
  end

  def save!
    save
  end

  def new_record?
    id.nil?
  end

  def ==(o)
    if o.instance_of? self.class
      o && o.id == id
    else
      false
    end
  end

  def eql?(o)
    self == o
  end

  def hash
    id
  end

  def repo
    self.class.repo
  end

  def inspect
    "<#{self.class.name}:#{id}>"
  end
end
```

An example repo:

```ruby
class UserRepo
  extend Chassis::Repo::Delegation

  class UnknownTokenError < StandardError
    def initialize(token)
      @token = token
    end

    def to_s
      "Could not identifiy user with token: #{@token}"
    end
  end

  class UnknownPhoneNumber < StandardError
    def initialize(phone_number)
      @phone_number = phone_number
    end

    def to_s
      "Could not identifiy user with phone number: #{@phone_number}"
    end
  end

  class << self
    def find_by_token!(token)
      user = query UserWithToken.new(token)
      raise UnknownTokenError, token if user.nil?
      user
    end

    def find_by_phone_number!(phone_number)
      user = query UserWithPhoneNumber.new(phone_number)
      raise UnknownPhoneNumber, phone_number if user.nil?
      user
    end
  end
end

UserWithToken = Struct.new :token
UserWithPhoneNumber = Struct.new :phone_number
```

Finally my in memory adapter for testing.

```ruby
class InMemoryAdapter < Chassis::Repo::InMemoryAdapter
  def query_auth_token_with_code(klass, q)
    all(klass).find do |auth_token|
      auth_token.code == q.code
    end
  end

  def query_user_with_token(klass, q)
    all(klass).find do |user|
      user.token == q.token
    end
  end

  def query_user_with_phone_number(klass, q)
    all(klass).find do |user|
      user.phone_number == q.phone_number
    end
  end

  def query_groups_for_user(klass, q)
    set = all(klass).select do |group|
      group.users.include? q.user
    end

    if q.updated_after
      set.select! do |group|
        group.updated_at.utc >= q.updated_after.utc
      end
    end

    set
  end
end
```

## At the End

I've covered a lot of ground in this post so I'll sum it up with
bullets at the end.

* Boundaries, Boundaries, Boundaries!
* Use cases: single use objects representing system functions.
* Forms objects as border guards (implement with Virtus).
* Repoistory + Query patterns for complete separation of business
  objects and data storge.
* Web delivery mechanisms with Sinatra.
* Be bitchy, raise a lot of meaningful errors.
* Logicless views only!
* `ActiveModel::Serializers` for generation JSON
* Fight against dependencies! Less is **always** better
* Fight against C-extensions. Strive for interperter agnostic code!
* Write uses cases and domain objects like how you speak about them.
  Let code read like a conversation instead of a technical
  explantation of what it's doing.
* Fail early, loudly, and often.
* Avoid proxy presenters. Views/Templates should only have access
  through explicit declarations.
* [Bow Before MiniTest](https://speakerdeck.com/ahawkins/bow-before-minitest)
* Use services objects for context less interaction with external
  services -- then provided a fake implementation for testing.
* Check out [Chassis](https://github.com/ahawkins/chassis). It
  contains a lot of code used in my applications these days. Its the
  container for all my shared abstractions.
* Checkout my [paper](https://github.com/ahawkins/hawkins.io/pull/7) 
  if you're interested in my abstract and longform stuff.

**Pretty please** ask me to pair with you if you want to explore this
sort of stuff in your applications. Hopefully you'll see me at some
confernces this year talking about this stuff. Tweet me if you have
something to say!
