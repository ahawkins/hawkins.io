---
layout: post
title: "Minitest & Mutant"

I met the wickedly smart [mbj](https://twitter.com/_m_b_j_/) at
Wroclove.rb. He's the man behind [mutant](https://github.com/mbj/mutant).
Mutant is a mutation testing tool for Ruby. If you're unfamiliar with
mutation testing, mutation test modifies your program's source code
and run tests. If the tests still pass then you have a problem. You
can learn more about Mutant by watching his
[talk](https://www.youtube.com/watch?v=rz-lFKEioLk).

Unfortunately, Mutant only integrated with RSpec. I am a shameless
minitest fanboy. I wanted, nay, I needed to start mutation testing my
code. The only solution was to pair with Markus and write it. That's
what we did. **Mutant now supports minitest!**

Mutant's minitest integration is different than rspec. This is because
rspec generates more meta-data about individual specs. It's possible
for mutant to identify an individual spec for a given mutatation and
execute it. This is not possible in minitest. So we made a compromise.
Mutant will run the entire test suite for every mutation. Of course
this is not feasible for large projects, but it will at least run out
of the box. You must implement more complex detection logic if this
does not work for you. This is done by defining
`MiniTest.mutant_killers`. More on this later. Secondly, you cannot
require `minitest/autorun` if running with mutant. This prevents the
tests running outside of mutant's control. So there are few things to
do. Thirdly, it assumes that `mutant` is run from the projet root, and
all the tests files are in `test/` and end in `_test.rb`.

```ruby
# test/test_helper.rb

require 'minitest/unit'

# Do not automatically run tests with
require 'minitest/autorun' unless ENV['MUTANT']


# test/greeter_test.rb
require_relative 'test_helper'

class GreeterTest < MiniTest::Unit::TestCase
  def test_greeting
    assert_equal 'Hej!', Greeter.new.greeting
  end
end

# greeter.rb

class Greeter
  def greeting
    'Hej!'
  end
end
```

Given that file structure: `greeter.rb`, `test/test_helper.rb`, and
`test/greeter_test.rb` it is not possible to execute mutant from the
command line. Use the `minitest` strategy: `bundle exec mutant -r
greeter --use minitest '::Greeter'` and you're off to the races.
Naturally it makes more sense to put this in a `Rakefile`.

```ruby
task :mutant do
  sh "bundle exec mutant --use minitest '::Greeter'"
end
```

I mentioned that you can also define `MiniTest.mutant_killers` for
more complex matching logic. This method should return an array of
of runnable things.

```ruby
class MiniTest
  def self.mutant_killers(subject)
    # here's where you inspect the subject mutation
    # and spit out the correct tests

    [
      FooTestCase.new(:test_bar_method),
      BarTestCase.new(:test_baz_method)
    ]
  end
end
```

Then mutant will execute those tests for you.

You can follow the work done adding mutation testing with minitest to
Harness in a [pull
request](https://github.com/ahawkins/harness/pull/22).

Go forth a mutate!
