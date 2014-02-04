---
title: "Amendments & Clarifications"
layout: post
---

I published the last post in the [Joy of
Design](/2014/01/rediscovering-the-joy-of-design/) series about a week
ago. Since then I've received many questions, concerns, and various
feedback. This post addresses the common ones. I may add more follow
up posts or simply add onto this post.

## What's a Boundary

I had a lengthy dicussion with a coworker about this term. Good
software architecture contains layers. Each layer builds upon the
next. The [OSI Model](http://en.wikipedia.org/wiki/OSI_model) is an
example. Each layer is ignorant to what's above or below it.
Dependencies flow one way. A boundary is where one layer meets
another. A boundary is there if one side can be swapped for a
completely different implementation without having to change the
other. That's to say there is no knowledge about the other. The
repository pattern is a great example. Objects ask the repository for
objects. The repository does whatever to provide the objects. The
reposistory object is a boundary. The repository's implemenation could
change without callers knowing about it. [Ars
Technica](http://arstechnica.com/information-technology/2014/02/why-isolate-lower-application-layers-from-higher-layers/)
has more on this topic.

## Uniqueness Validations

I received a question about uniqueness validations. How should a
unique email/username be implemented? Then what if the uniqueness
depends on an account or other value? I was happy that someone asked
this question because it forces you to make a design decision.
Implementing the validation is easy. Create a validator that queries
the repository with the given values and test there are no matches.
The real question is: _where_ should this be implemented? Should it go
into the form or into a use case?

Now we're off on a topic. Form objects should be context free. They
should focus on input collection and validation. They should not need
to interact with the outside world to do their job. That means they
should have no collabarators. But wait, uniques validation is an input
concern is it not? Well perhaps. Take the simple case where uniqueness
simply checks against one value. Is that context free? What about a
more complex case where uniquness takes three or four other objects?
There comes a point where it seems the validations are domain model
specific and not input specific. Consider a simple validations like
required values or email address formats. These are context fee. The
form does not need to know _how_ this value is used. Now switch back
to the uniqueness problem. The form validations would contain domain
specific validation. How does the form know that email address should
be unique to a given project/customer or account? The correct answer
is that it should not. This logic should be implemented in the
contextual object in the system: the use case. I prefer to keep this
these use case specific concerns in the use cases themselves. This
ensures the form object have no collaborators. However this adds more
logic to the use cases and increase their number of collabarators.
This is a tradeoff I'm willing to make. Yes, it is possible to
implement the validation in the form but implementing it in the use
case makes more sense in more cases and thusly is a better common
solution.

Now the only question is how to do the validation. This is straight
forward using the repository. Query the repository and check the
results are `empty?` or `nil`. I'm still using
`ActiveModel::Validations` (nothing better yet). I prefer to decorate
the form with extra validators. I create a validator class for the use
case, validate the form, then run the extra validations.

```ruby
class CreateUser
  class FormValidator
    class UserNameValidator < ActiveModel::Validator
      def validate(form)
        existing_users = UserRepo.named form.user_name
        record.errors.add :base, "user name is already taken!" if !existing_users.empty?
      end
    end

    include Validations
    include ActiveModel::Validations

    validates_with :user_name, FormValidator

    def initialize(form)
      @form = form
    end

    def user_name
      @form.user_name
    end
  end

  def run!
    form.validate!
    # pass in other things to check uniqueness with here
    # In this case "FormValidator" handles use case specific
    # validations
    FormValidator.new(form).validate!

    # other stuff
  end
end
```

# Test Suites

The blog posts contained example tests, but never anything real about
the entire test suite. How did I miss that? Well, here's my attempt at
making it right.

My test suites contain multiple types of tests designed to run in
multiple modes. There are two modes: fast and slow. "fast" is default.
"fast" runs all the tests using fake implemenations of all external
things. "slow" uses real implementations of all external services. I
use the slow mode when I'm developing to ensure that each class has
the correct collabrators and that data is moving correctly through the
system. Once that is correct, I run the tests in slow mode to test the
data is hitting the external world correctly. In practice "slow" is
for CI.

The tests are broken up into categories. They all
build off `MiniTest::Unit::TestCase`. All adapters/caches/services use
null implmentations. This makes it impossible to touch the outside
world. Interaction with these services should not generally
happen in unit tests--but if they do it doesn't matter. Next come
integration tests. These tests use fake implementations. IE the
repository uses an in memory implementation. This way I can test data
flowing through the entire system without slowing down the tests. Next
acceptance tests. Acceptance tests use fake implementations as well,
but they go through the delivery mechanism. In practice it works out
like this:

* `AcceptanceTestCase` - through the delivery mechanism using fake
  implementations
* `IntegrationTestCase` - test multiple objects using fake
  implementations
* `MiniTest::Unit::TestCase` - test a single class in isolate without
  talking to the outside world

The "fake" implementations are switched in CI mode. So the in memory
adapter would be replaces with a redis implementation. The cache would
talk to memcached etc.

The various adapters are tested in isolation. IE, I can test the
repository is writing to postgresql correctly.

Here are some rake tasks:

* `rake` - run all tests using fake adapters
* `ADAPTER=pg rake test` - run all tests with integration and
  acceptance tests talking to postgres.
* `CACHE=memcache rake test` - run all tests with integration and
  acceptance tests talking to memcache.
* `CI=true rake test` - run all tests with integration and
  acceptance tests talking to memcache/postres.
* `rake test:acceptance` - run all acceptance tests
* `rake test:integration` - run all integration tests (usually use
  case tests)
* `rake test:repo` - run tests for repo queries and things like that
* `rake test:entities` - run tests for all the entitites
* `rake test:forms` - run tests for all the forms
* `rake test:smoke` - run a small set of super important tests

I run use this for ci: `CI=true rake test:smoke test:ci`. This runs
the most important smoke tests using real implementations. If
everything's passing then run the entire suite against real
implementations. Note, travis will set the `CI` environment variable
for you.

This setup is perfect. Following boundary principles keeps the test
suite insanely fast. Also there is no bullshit framework to load so
even loading ruby is fast. Then through a combination of unit tests
and end-to-end integration tests I have more confidence in my
applications then I ever did before. This takes almost all the fear
out of continous delivery.

One final note about testing. I want to share some information about
code paths. It is important that the application only has a single
code path. The implementation is an object and not checking a setting
then behaving in two different ways. Rails conventions absoutely fail
in this case. Rails disabled caching in the test environment by
default. This causes all controller and view related code to act in
two different ways (if caching is enabled to this, otherwise do this).
This is **horrible practice.** The active support cache implementation
contains a null and in memory implementation. Instead of switching
caching to off, set the cache to a null implementation. This is also
horrible practice because the code that runs in test is *not* the code
that runs in production. The entire point of tests is to ensure code
performs correctly in production. You must make the correct decisions
to make this goal. I cannot tell you how many random bugs I found in
Radium related to caching with memcache and marhsaling objects. I
could have **only** found these bugs by running the tests using a real
cache. So please, customize behavior through objects and not through
settings. This will make the code better and give you more confidence
its in true behavior.
