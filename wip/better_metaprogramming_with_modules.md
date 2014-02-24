---
layout: post
title: "Better Metaprogramming with Modules"
---

Ruby is a wonderfully dynamic language. I'm constantly surprised just
_how_ dynamic it is. If you can think of something, you can usually do
it--you just have to know which buttons to push. I've written a lot of
Ruby code for fun and profit over the years. I've pushed a gem or two
in my time. Eventually metaprogramming enters the mix. Metaprogramming
is an awesome solution to a certain set of problems. I found Ruby's
metaprogramming capabilities the best at solving macro type problems.
Ruby's standard library uses this approach all over the place. If
you've ever required `delegate` and used `def_delegators` you know
exactly what I'm talking about. Rubyists turn to metaprogramming to
solve a bunch of problems and it usually works out well.

Naturally there is always the opposition. They don't like
metaprogramming. They always have their reasons. I think many people
got turned off of metaprogramming through Rails's bad practices (there
are many). Let's look at some low hanging fruit: `alias_method_chain`.
This is the probably the most bastardized method in the entire
ecosystem. `alias_method_chain` works by creating an alias (thusly
copying the implementation) and allowing you to insert a new method
and call the original implementation. (Astute readers will realize is
almost like `Module.prepend`). `What that boils down to is a
very complex way to implement `super`. This is a work around for rails
metaprogramming problems. Let's use the wonderfully ill-fated
`accepts_nested_attributes_for` example. The problems with this
method have been well documented, but it still serves at the textbook
example of how metaprogamming can make things much more difficult to
reason about. `accepts_nested_attributes_for` would programmatically
define methods onto the current scope. So now let's say you have a
case where you need to customize this behavior. You may think, I can
define a method in my class and call `super`. You'd be mistaken. Since
the implementation is defined directly on the class itself there is no
superclass implementation. The call to `super` fails. Thusly you need
to use `alias_method_chain` to copy the method dynamically defined by
`accepts_nested_attributes_for` then call it from the refined method.
This is a case of metaprogramming gone wrong. There is a way around
this problem. The answer is modules.

Ruby can dynamically generate modules at runtime and insert them into
the class hierarchy. This maintains `super` at all times without
compromising ability to metaprogram . So instead of defining a method
directly on the class, we'd dynamically generate a module and include
that in the class. Now the class can call `super` as expected. This is
metaprogramming done right. Here are some notable examples. I first
saw this from Piotr Solnica and Virtus. Virtus is a perfect project
and Piotr is becoming one of my favorite Rubyists because of how he
commands Ruby. A class acquires virtus' functionality by including a
module. Here's an example:

```ruby
class User
  include Virtus.model

  attribute name, String
  attribute email, EmailAddress
end
```

`Virtus.model` is a method that returns a dynamically generated
module. You can customize the modules behavior by passing methods to
`model` or with a block. Here's an example from the readme.

```ruby
# include just the attribute DSL
class User
  include Virtus.model(:constructor => false, :mass_assignment => false)

  attribute :name, String
end
```

I recommend you read the virtus source on how to use this technique.
Konstantin Hasse recently released a library containing a good
metaprogramming examples as well. Here's an example:

```ruby
# https://raw2.github.com/rkh/tool/master/lib/tool/warning_filter.rb
require 'delegate'

module Tool
  # Enables Ruby's built-in warnings (-w) but filters out those caused by third-party gems.
  # Does not invlove any manual set up.
  #
  # @example
  #   require 'tool/warning_filter'
  #   Foo = 10
  #   Foo = 20
  class WarningFilter < DelegateClass(IO)
    $stderr  = new($stderr)
    $VERBOSE = true

    # @!visibility private
    def write(line)
      super if line !~ /^\S+gems\/ruby\-\S+:\d+: warning:/
    end
  end
end
```

That was the first time I was exposed to `DelegateClass`. Seems like
an interesting way to mimic functionality. This is an important
example because the `write` method can be redefined and `super` can be
called. This is metaprogramming done correctly!

I have adopted this technique personally and professionally.
[Chassis](https://github.com/ahawkins/chassis) uses this technique
exclusively. `Chassis::Strategy` uses a dynamically created module.
Here's an example from the readme:

```ruby
class Mailer
  include Chassis.strategy(:deliver)

  def deliver(mail)
    raise "No address" unless mail.to
    super
  end
end
```

Here are some more useful examples from other projects using this
approach. [Concord](https://github.com/mbj/concord) and
[Equalizer](https://github.com/dkubb/equalizer) are both handy
projects. Check each project's readme for examples.

In short, I **wholeheartedly** suggest you adopt this metaprogramming
style. It is far superior than directly defining methods on the class
at runtime because `super` works in obvious ways.
