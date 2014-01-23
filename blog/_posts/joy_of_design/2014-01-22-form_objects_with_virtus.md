---
title: "Form Objects with Virtus"
layout: post
---

A delivery mechanism provides the world access to your app. Form
objects are code's access to the rest of your code. They are the outer
border around the domain entities. Avdi Grimm put it very nicely. He
described form object as boarder guards. They validate and verify that
all data coming into the system is correct. Once the data moves past
the checkpoint it is not checked again.

This is a powerful abstraction because it provides a single place to
handle input coercion. What is input coercion? Input coercion is
turning garbage data into proper types. Let's examine some cases. Your
program needs to read a number from `STDIN`. `STDIN` only knows about
text. Eventually a `to_i` call happens. Then there is a number. The
same thing can be said about date/time parsing. The situation is just
the same for web applications. Standard URL encoded data is all
strings and simply enters the application as a gigantic hash.  Having
the raw data is great, but it's not what we want to work with.  If the
application needs a `Time` it should get a `Time`. If it needs to be a
`Customer` than so be it. The form object's job is to provide all the
correct objects to use cases.

## All Hail Virtus

I don't remember how I came across Virtus, but once I did I fell in
love with the project. Virtus was extracted from the datamapper
project. Its primary use case is inside ROM (Ruby Object Mapper) to
declare attributes and types. It does built in coercion for many core
types. This is important because its primary role is to coerce
whatever data has been stored in some table somewhere. All that being
said, it makes creating form objects easy and straight forward.  It
has a simple and descriptive API.

```ruby
class CreateUserForm
  include Virtus.model

  attribute :name, String
  attribute :auth_token, String
  attribute :device, DeviceForm
  attribute :account, Account
  attribute :friends, Array[User]
end
```

[Virtus](https://github.com/solnic/virtus) has a well documented API.
The readme contains everything you want to know. Virtus really shines
when using its coercions. Here's an example. All applications should
only work in UTC time. Virtus can ensure all time objects are in UTC
before entering the wider system.

```ruby
class UTCTime < Virtus::Attribute
  def coerce(value)
    value.is_a?(::Time) ? value.utc : value.to_utc
  end
end

class PhotoUpload
  include Virtus.model

  attribute :timestamp, UTCTime
end
```

Voilla. Now all times will be in UTC. You can define coercions for
everything. This is especially handy when you want to deal with model
class. Consider a JSON API. It cannot send a Ruby object, so it sends
an id. The ID is used to lookup the real object.

```ruby
class CustomerAssociation < Virtus::Attribute
  def coerce(value)
    value.is_a?(Customer) ? value : CustomerRepo.find(value)
  end
end

class Todo
  include Virtus.model

  attribute :customer, CustomerAssociation
end
```

This works, but I find it clunky. The Virtus API changed in 1.0. You
were allowed to pass a `:coercer` class to `attribute`.  This was nice
because you could provide anonymous coercers.  Now I feel it's easier
to override the writer method. This does not require creating a class
like `CustomerAssociation`.

```ruby
class Todo
  include Virtus.model

  attribute :customer, Customer

  def customer=(value)
    value.is_a?(Customer) ? super : super(CustomerRepo.find(value))
  end
end
```

You can do a lot of things with coercions and writer methods--whatever
it takes to get the right classes.

## Protecting Yourself

I also guard against common exceptions from initializing with grab bag
hashes. Every Ruby programmer has done something like: `Post.new
some_gigantic_hash`. That's OK, but you have to protect yourself.
When `some_gigantic_hash` comes from the web god knows what it
contains. The hash may contain keys that are not implemented. Instead
of getting undefined method errors, I change the constructor to raise
a specific error.

```ruby
class UnknownFieldError < RuntimeError
  def initialize(name)
    @name
  end

  def to_s
    "#{@name} given, but not declared in the form."
  end
end

class SignupForm
  include Virtus.model

  def initialize(*args, &block)
    args.each_key do |key, value|
      raise UnknownFieldError, key unless respond_to?("#{key}=")
    end

    super
  end
end
```

Now a delivery mechanism may capture the error and act accordingly.
It also saves you from typos and other weird stuff happening in
tests.

## Validations

Forms should also validate their input. I've been using
`ActiveModel::Validations` simply because there is no clear
alternative. I'd love to move away, so if you know of something please
let me know. I do things slightly differently. I have a
`ValidationError` and `validate!` methods. This is the entire public
interface for working with validations. This keeps the wider systems
ignorant to how validations actually happen. The use cases call
`validate!` before doing anything. They should not continue in any
circumstance if the data is invalid.

```ruby
ValidationError = Class.new RuntimeError

class CreateUserForm
  include Vritus.model
  include ActiveModel::Validations

  attribute :name, String
  attribute :auth_token, String
  attribute :device, Hash

  validates :name, :auth_token, :device, presence: true

  validate do |form|
    next unless form.device

    uuid = form.device.fetch 'uuid', nil
    errors.add :device, "uuid cannot be blank" if uuid.blank?
  end

  def validate!
    raise ValidationError, errors unless valid?
  end
end
```

Naturally there are times when you need more context to perform
validations. The use cases takes in the state/context and
creates validator classes. In short the forms are stateless. The use
case may combine them with state to add more contextual validation.

## That's a Wrap

That's everything I have to say about form objects. The
[paper](https://github.com/ahawkins/hawkins.io/pull/7) contains more
discussion on their larger role and how other objects interact with
them. Virtus' powerful coercions ensure the consumer always has the
correct type. No working with strings or foreign keys.  Forms convert
junk data into domain objects. Work with those and nothing else. I
think you'll really enjoy Virtus the more you use it.  If you haven't
used it and you're working with Rails, it is a great library for
creating objects that work with Rails' form builders.

The next post covers writing the most important object in the system:
[use cases](/2014/01/writing_use_cases/). I hope you like it.
