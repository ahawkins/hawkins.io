---
title: "Registries & Avoiding Metaprogamming"
layout: post
---

I've been working on an application that includes a lot of
polymorphism. We operate a classifieds site. Postings include a custom
property list. These can be things like text, numbers, enums (think
selects), multi fields (like enum's but user can choose multiple),
composites, and a host of other combinations. There is nothing unique
about this arrangement. It does require a lot of leg work to keep
everything moving. Consider this, the user's input must be checked
against a given set of allowed properties. This includes the type,
validations, and other metadata about the given property. The input
must coerced, validated, saved, and eventually serialized back as
JSON. All of this depends on some configuration information.
Previously I would've turned to metaprogramming to make this all
happen. Instead I'm much happier using a registry.

I think many ruby programmers tend towards metaprogramming solutions
since they're so popular inside rails. The typical metaprogramming
would solution was initially the most straightforward, but it it
was not testable.

I tried a metaprogramming solution that did automatic constant lookup
based on property type or class. Here's an example. If the given
property is a `TextField` the validator could do something like this:
`validator = "#{property.class}Validator".constantize"`. This approach
would work with things like `TextFieldCoercer`, `TextFieldFormatter`,
and `TextFieldSerializer`. This approach is problematic. First off,
testing this is difficult. Testing requires defining a new constant
inside the test case and doing some subclassing to get everything
inside the same scope. Second, the connection between classes is
implicit. One may be able to deduce this relationship but
it's certainly not explicit. Third, it makes the assumption that the
class itself is enough information to decide what to use. This may not
be a problem in all problem domains, but it is in our case. Example a
given property may act different depending on context. The class
cannot communicate this. One might say subclass, but is
that really a good solution? I don't think so. You should not create a
subclass to indicate different behavior to the external system. So a
better solution was needed.

There was a secondary motivation for this. It became obvious through
testing that we could represent most functionality through a base
class. For example all text fields could be validated or coerced the
same way, just like all number fields. So what we did was create a new
constant pointing to the base implementation (`TextFieldValidator =
GenericValidator`) and so on for all the fields that worked with. This
seemed less than ideal. We were creating a bunch of constants for no
reason other than to satisfy runtime constant lookup.

We took all of this into account and decided to go with a registry
instead. The classes that interacted with properties ask the registry
which implementation to use and go on about their business. This has
three key benefits. First, the caller is unaware of what actually
happens to provide the correct implementation. Second, the registry
object can be passed as an argument during testing to simulate any
number of scenarios. Third, the instance itself is the matching
criteria. This allows the registry itself to implement more complex
detection strategies (simple class match, attribute detection, or
implementations tied to a specific instance). Forth, the mapping is
explicit and can be tested. So what we end up is one file that
registers all the implementations and one object that uses the
registry at runtime. Here's an example.

```ruby
# Chassis::Registry is essentially a simple hash, with one notable
# quality: all lookups return a value or fail.
FieldFormatterRegistry = Class.new Chassis::Registry do
  include Singleton

  # Registry itself knows about more complicated detection
  # scenarios. It would be possible to register more implementations
  # using lambdas to match more complex cases.
  def fetch(field)
    if map.key? field
      fetch field
    elsif map.key? field.type
      fetch field.type
    else
      super
    end
  end
end
end.instance

class SimpleFieldFormatter
  # implementation
end

class EnumFieldFormatter
  # implementation
end

FieldFormatterRegistry[:text] = SimpleFormatter
FieldFormatterRegistry[:integer] = SimpleFormatter
FieldFormatterRegistry[:float] = SimpleFormatter
# And so on.
FieldFormatterRegistry[:enum] = EnumFormatter
FieldFormatterRegistry[1] = SomeVerySpecificFormatter
```

Now finally we can use the registry.

```ruby
class PropertiesFormatter
  attr_reader :fields, :registry

  # Use dependency injection w/default argument. This allows the
  # registry to be passed in during tests, but the wider system
  # doesn't have know about the prefered default.
  def initialize(fields, registry = FieldFormatterRegistry)
    @fields, @registry = field, registry
  end

  def format
    fields.map do |field|
      formatter_class = registry.fetch field
      formatter_class.new(field).format
    end
  end
end
```

And that's a wrap! The registry mimics `Hash` so it can be replaced
with a simple hash in tests. This approach has made the application
easier to understand and made me a happier programmer.
