---
title: "Writing Use Cases"
layout: post
---

Use cases take in a form and external state (often the current user)
and do something. Use cases are appropriately named: `CreateTodo`,
`UploadPicture`, or `PostAd`. No REST here! Use cases are isolated and
agnostic. A use case has a `run!` method (with varying signatures
depending on context) and it returns an object.  Failures are
communicated through exceptions. I like exceptions. I use exceptions
much more now. They prevent a lot of weird stuff from happening. I
usually have at least `ValidationError` and `PermissionDeniedError`.
I've never worked on app that didn't have validations or permissions.
Each use case may raise its own specific errors like
`AccountCapacityExceededError` that only happen when certain objects
are used in concert. I prefer this approach because the delivery
mechanism can capture errors and react accordingly. The errors are
also helpful since they have useful failure messages.  This had made
debugging random tests failures much easier because unexpected errors
are clearly presented. How many times have written a test that fails
in a weird way because code assumed valid data? That happened a lot to
me. It still happens, but raising an error makes root cause diagnose
easy.

Use cases are also fantastic because new use cases can be composed of
existing ones. I cannot express how awesome this is. I saw it
for the first time in Radium. I had an existing use case:
`CreateContact`. I had to write a new use case: `SendEmail`.
`SendEmail` needed to create new contacts when it encountered unknown
email addresses. At that moment I realized I could simply instantiate
a new `ContactForm` and `CreateContact` use case and call them from
inside `SendEmail`. It worked perfectly. I could never go back after
that moment. I actually consider it a defining moment in my software
development progression. I previously would've done that with a ton of
callbacks while violating a ton of boundaries and other sound design
principles. I cannot stress how important use cases are. It will blow
your mind when they're composed for the first time.

## General Structure

The use case initializer has two different signatures.
`def initialize(form, current_user)` is the most common.
`def initialize(record_id, form, current_user)` is for when you
need to retrieve a record as part of the use case. I prefer to pass
the ID instead of the object because only the internal parts know how
to lookup objects. I'm still debating this point internally, but this
how I do today.

The use case has two internal helper methods: `validate!`, and
`authorize!`. `validate!` may also take a block so an object's
validations can be combined with state or other objects. Here's an
example:

```ruby
def run!
  form.validate! do |form|
    next unless form.signup?
    form.signup && current_account.has_space?
  end
end
```

The `validate!` helper raises a `ValidationError` if the block does not
return true. The block may also raise its own errors.

The `authorize!` helper takes no arguments. It contains required
permission logic. Every application I've worked on had different
access rules so I gave up on trying to define a general helper.
Instead my domain entities have an `accessible_by?(thing)` method
that does exactly what it says. Then in the use cases, I can query all
the accessible by logic or compose it for the desired effect.

```ruby
def authorize!
  if !contact.accessible_by? current_user
    fail PermissionError, contact
  end

  if assigned_to && !assigned_to.accessible_by?(current_user)
    fail PermissionError, assigned_to
  end
end
```

The `run!` method is flexible. Initially all `run!` methods start out
with that signature. Things change when use cases are composed. In the
`SendEmail` scenario I described earlier, it needed to create
contacts. The `SendEmail` use case needed to modify the contacts
before they were saved. Initially I thought about subclassing
`CreateContact` but then I remembered Avdi Grim talking about extending
functionality with blocks. That's exactly what I did. I introduced `run!` with an
optional block. This made things so powerful since the other use cases
could tie into logic at the right time. It's up to the use case when it
should `yield`, but my use cases usually `yield` right before the `save`
call happens. I yield the use case's main object at a minimum.

## Domain Events

Domain entities have their own life cycle and things that happen on
them. A contact knows when it has been reassigned and a deal knows
when it has been closed. The classes uses the observer pattern to send
events. What happens when you need to do something with this
information? Consider you need to create an activity feed: who did
what to what and when. The entities are emitting events but they don't
know _who_ did them--just that they happened. This is where the use
case comes in. The use case is the only contextual object in the system.
It can observe these events, combine them with context, and then act
accordingly. Here's an example:

```ruby
class UpdateInvitation
  attr_reader :invitation_id, :form, :current_user

  def initialize(invitation_id, form, current_user)
    @invitation_id, @form, @current_user = invitaiton_id, form, current_user
  end

  def run!
    invitation = InvitationRepo.find invitation_id

    invitation.add_observer self

    # manipulate the invitation
  end

  private
  def invitation_confirmed(invitation, invitee)
    ActivityLog.invitation_confirmed invitation, invitee, current_user
  end
end
```

## The Skeleton

Here's my basic use case skeleton. It contains the bare minimum.
Modify as you see fit.

```ruby
class CreateContact
  attr_reader :form, :current_user

  def initialize(form, current_user)
    @form, @current_user = form, current_user
  end

  def run!
    validate! and authorize!

    contact = Contact.new 

    # do stuff with the form and assign attributes

    yield contact if block_given?

    contact.save

    contact
  end

  private
  def validate!
    form.validate!
    # followed by any other context specific validation
  end

  def authorize!
    # permission logic
  end
end
```

## Real World Example

I leave you with an example from the photo sharing application I'm
working on. This file exactly as it is in git.

<script src="https://gist.github.com/ahawkins/45504e66d48723f86436.js"></script>

What would the code be without the test?

<script src="https://gist.github.com/ahawkins/6ed8b5b9fc96b3dfc4d4.js"></script>

## Go Forth and Use Case

That's it for use cases. That covers all the quirks and patterns in
writing my use cases. The structure is the same, but boy I tell you,
that `run!` method can get gnarly at times. Use cases have been a
positive force since I introduced them. I know they will be for you
too.

The next post continues the dive down the rabbit hole. We started at
the outermost layer with delivery mechanisms (that took a while),
followed by form objects, and now finally to use cases. The example
code shows use cases interacting with many other classes. These are
[domain entities](/2014/01/entities/) and the next post is all about them.
