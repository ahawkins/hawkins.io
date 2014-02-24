---
title: "Abstract Ruby Classes with Factories"
layout: post
---

I hate to say this, but I like the idea of Java style abstract
classes--especially when paired with an interface implementation. This
is nice thing to have. You can mimic it in ruby but it's never 100%
the same. It's not possible to get it 100% right because Ruby is
dynamically typed and Java is static and compiled. But the spirit
lives on! I've found myself working with interfaces/protocols much
more these days. You can usually create a generic abstract class that
would work when a subclass implements the missing bits (template
method pattern). I've come up with something that in theory works
pretty well but lacks on key feature.

My approach uses a factory, `class_eval`, and an anonymous class. This
makes is impossible use the abstract class without providing an
implementation. The approach looks like this:

```ruby
class PriceCalculator
  class << self
    # Declare shared functionality in modules so subclasses may
    # call super if they desire.
    module InstanceMethods
      def method_a
        # blah
      end

      def method_b
        # blah
      end

      def price
        fail NotImplementedError, "subclass must implement"
      end
    end

    module ClassMethods
      def class_method_a
        # blah
      end
    end

    def build(&block)
      fail ArgumentError, "block required!" unless block?

      Class.new do
        extend ClassMethods
        include InstanceMethods

        # block is evaluated so new methods can be defined
        # or existing ones redefined. super works correctly
        # as you'd expect.
        class_eval(&block)
      end
    end
  end
end
```

Now we simply call `PriceCalculator.build` with a block and define the
class like normal.

```ruby
ConstantPriceCalculator = PriceCalculator.build do
  def price
    10
  end
end

LotteryPriceCalculator = PriceCalculator.build do
  def price
    rand * 10
  end
end
```

This all works **perfectly** until you want to define an inner
constant.

```ruby
class LotteryPriceCalculator = PriceCalculator.build do
  Results = Struct.new :foo, :bar

  def price
    # use Results in some way to calculate a price
  end
end
```

An error occurs the moment `LotteryPriceCalculator::Results`
`Results` is referenced in the wrong way. `Results` is
defined in the global namespace! I certainly don't want that! Right
now I don't see a way around this in this implementation. Which is
a shame because I really like it! It feels more ruby-esque and has the
desirable property that the abstract implementation cannot be used
directly. If anyone knows a way around this please let me know! It
seems something is possible in C (Struct is implemented in C) but I
don't want that. I create inner classes often which means this
approach will not work for me. So for the time being I've settled on
having an actual base class then subclassing. I know there is an
abstract thing in ActiveSupport but that is undesirable. So my fellow
ruby programmers, how do you make this happen in your applications?

I asked [Piotr Solnica](http://twitter.com/_solnic_) to review this
post in hopes he found a solution. Naturally the ROM guys have
something small and portable. They've gone with the explicitly defined
subclass approach in
[`abstract_type`](https://github.com/dkubb/abstract_type). Check it
out if you want a simple way to create abstracts.
