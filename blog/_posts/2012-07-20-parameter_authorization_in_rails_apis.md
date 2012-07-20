---
layout: post
title: Parameter Authorization in Rails API's
tags: [rails, api]
---

Every application manages permissions in their own way. I work
exclusively with API style apps (Read I only care about JSON). In my
application users can access certain parts of the API. Inside each
action they may have access to different things. There are two layers:
can they use this action? Can they send these parameters? I describe how
I solved this problem and how you can do the same.

## Layer 1: Authorization Actions

I use [CanCan](https://github.com/ryanb/cancan/) to authorize users and
actions. I **only** use cancan for high level permissions. Here's what I
use CanCan for:

* the `accessibly_by` scope to retreive records for `GET /collection`
  routes
* `authorize! :read, @foo`: does the user have general access an
  individual resource or action.

I do not use cancan for specific attribute authorization. This feature
is coming in version 2, but I have my doubts on it's useabilty. The
current version of cancan is perfect for these two general use cases. It
currently supports some sort of parameter authorization but it's based
on declaring scopes and other witchcraft. This may work for you, but it
does not work in my application. CanCan is very well documented in the
wiki and by Railscasts. I will not cover it here. I will cover layer 2
because that's new and fun :)

## Layer 2: Authorizing Parameters

`attr_accessible` does not scale. It works for simple apps but it
doesn't scale when you need to consider the current user.
`attr_accessible` also keeps permissions logic in the model itself. I do
not agree with this. I think permissions logic should be kept in it's
_own_ model. Data models should stay just that: data. 

Rails 4 takes a new approach. Controllers decide what parameters are
passed to the model. Why? Because they have access to the
`current_user`. This also creates a separation of concerns. These are
both good things. DHH wrote [StrongParameters](https://github.com/rails/strong_parameters/).
Thanks to the modularity of rails 3, you can use this as a plugin right
now! It will be standard in Rails 4--so an upgrade now wouldn't hurt.

`StrongParameters` introduces a simple DSL (DHH's favorite approach) to
state which parameters are allowed. Here's an example

```ruby
def create
  @post = Post.create params.require(:post).permit(:title, :text)
end
```

This does a few things:

1. It creates a special Permitted hash which inherits from Hash.
2. It raises an error if there is no `params[:post]`. This is good
   because it chokes on malformed requests.
3. Filters out the `params[:post]` hash to only include `:title` and
   `:text`.
4. The underlying hash is now passed to `Post.create` like usual.

This is a very simple example. You can also authorize nested hashes.
There are more complete examples in the readme. Basically, it's now up
to us to decide what attributes are passed to the model. It's easy to
see how this logic can become complicated. It make sense to extract that
logic into a reusable method. Here's the example from the readme:

```ruby
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
      params.require(:person).permit(:name, :age)
    end
end
```

The `person_params` method by become more complicated as time goes on.
Let's stay you need conditional logic:

```ruby
def person_params
  if current_user.admin?
    params.require(:person).permit(:name, :age, :status)
  else
    params.require(:person).permit(:name, :age)
  end
end
```

This is a simple conditional added. What happens when you need to add
more? You can continual to scale this up. This happened to me. It became
clear that I needed a new class to handle this. I decided to do this
because:

1. I wanted to test it in isolation
2. I had multiple conditions and branches
3. I wanted to encapsulate a pattern I saw in my code.

There are a few other uses cases I wanted to support:

* Nested conditional authorization. This is using nested attributes but
  attributes have to be authorized separate of the parent. For example
  you use reminders with nested attributes. What happens when they try
  to edit someone else's reminder through the parent they have access
  too.
* Mass association assignment. Certain users are allowed to set methods
  like: `association_ids`. This is great, but each ID has to be checked
  to see if it's allowed. Without it you could associate your stuff with
  other people's stuff!
* Authorization of associated attributes happens with cancan. In my use
  case you can set `user_id` if you have `assign` access to the parent
  and you can `read` the user you want to assign it to.

I started of with a class like this:

```ruby
class UserPermitter
  def initialize(params, user)
    @params, @user = params, user
  end

  def permitted_params
    params.require(:user).permit(:name, :email, :phone, :avatar)
  end

  private
  def params
    @params
  end

  def user
    @user
  end
end
```

Then I made another:

```ruby
class TodoPermitter
  def initialize(params, user)
    @params, @user = params, user
  end

  def permitted_params
    allowed_attributes = %w(kind finish_by finished description).map(&:to_sym)
    allowed_attributes << :user_id if permit_user_id?
    allowed_attributes << :campaign_id if permit_campaign_id?
    allowed_attributes << { :reminder_attributes => [ :time, :via ] }

    params.require(:todo).permit(*allowed_attributes)
  end

  private
  private
  def params
    @params
  end

  def user
    @user
  end

  def permit_user_id?
    return unless user_id

    other_user = User.find user_id
    authorize! :read, other_user
  end

  def permit_campaign_id?
    return unless campaign_id

    campaign = Campaign.find campaign_id
    authorize! :read, campaign
  end

  def user_id
    params[:todo][:user_id]
  end

  def campaign_id
    params[:todo][:campaign_id]
  end
end
```

There is already a pattern emerging. I also found very annoying aspect
in `StrongParamters`. You can only make on `permit` call. Calling `permit`
creates a new object with keys removed. This is why in the
`TodoPermitter` I collect all the attributes then use a splat to
generate hash. This example doesn't work like expected:

```
allowed = params.require(:todo)
allowed.permit(:things, :with, :no_permissions)
allowed.permit(:user_id) if permit_user_id`
allowed
```

It became clear that that the code will be very similar. I have to make
probably twenty of these classes. This would get old fast. Here's what I
noticed:

1. Describe the set of parameters everyone can access
2. Load record based on the `_id` method and check `read` access.
3. Collect all of those attributes and generate a permitted hash.
4. Define a standard interface

## Refactor: Extract Superclass & Write DSL

I knew this was the right way to do it. I proceeded on my duplication
way until I had written all the classes I needed. This took an hour or
so. Copy and paste code and tests. It was easy but took some time. Now
that I had all my tests passing it was time to refactor my code.

The first step was to extract a new superclass: `ApplicationPemitter`.
This classes defines the interface for all the others.

```ruby
class ApplicationPermitter
  def initialize(params, user)
    @params, @user = params, user
  end

  def permitted_params
    raise "Subclass mus implement this!"
  end

  private
  def params
    @params
  end

  def user
    @user
  end
end
```

Then I dutifully refactored my permitters to use the superclass until
the tests passed. Now it was time to handle the DSL for solving the
common problem. I took one class that illustrated the use cases and came
up with this. It's inspired by the lovely `ActiveModel::Serializers`.

```ruby
class DealPermitter < ApplicationPermitter
  # No premissions reuqired to set this
  permit :name, :description, :close_by, :state

  # can pass `:authorize` with a permission:
  # This line allows user_id if the user can read the user specified
  # by the user_id. This only happens if it's present
  permit :user_id, :authorize => :read

  # same thing but automatically handles arrays of ids as well.
  # This line allows the attachment_ids if the user can manage all
  # the specified attachments
  permit :attachment_ids, :authorize => :manage

  # same thing as before but scopes this it to the
  # hash inside the line_items_attributes array
  #
  # line_items_attributes is permitted if every item in the array
  # is allowed.
  # 
  # This also only allows line items if the user can manage the parent
  scope :line_items_attributes, :manage => true do |line_item|
    # So you cannot manipulate line items outside the parent
    line_item.permit :id, :authorize => :manage 

    line_item.permit :name, :quantity, :price, :currency, :notes
    line_item.permit :product_id, :authorize => :read
  end
end
```

I think that came out pretty well! It handles all my uses cases. It also
prevented me from writing code in the individual classes. I rewrote all
the individual classes using the DSL then just hacked away until all my
tests passed. It really didn't take too long. Here's the final class:

<script src="https://gist.github.com/3150306.js?file=application_permitter.rb"></script>

Cool! Now it's time to use these bad boys in inside my controllers.
Here's the code I used in `ApplicationController`:

```ruby
def permitted_params
  @permitted_params ||= permitter.permitted_params
end

def permitter
  return unless permitter_class

  @permitter ||= permitter_class.new params, current_user, current_ability
end

def permitter_class
  begin
    "#{self.class.to_s.match(/(.+)Controller/)[1].singularize}Permitter".constantize
  rescue NameError
    nil
  end
end
```

Now in my controllers I only use `permitted_params` and all is good!

I hope you enjoyed this post and learned something. Feel free to use my
code in your application if it suits your needs. I may release this as a
gem at some point as well.

Here's what a basic action looks like now:

```ruby
def create
  authorize! :create, Post
  
  @post = Post.new permitted_params
  # more stuff
end
```
