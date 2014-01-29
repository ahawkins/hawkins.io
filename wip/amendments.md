# Uniqueness Validations

I received a question regarding uniqueness validation and how to
handle that in a form, or if it should be handled in a form at all.
The uniques validation was scoped by another attribute. It would be
possible to handle this in a form or use case. It depends on where you
decide to draw the responsibility line. Should the form be more
contextual, or is it the use case's job to handle conceptual
semantics? I think it's best that the use case does does this. This
way the form's only responsiblity is to collect and coerce input.

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
    FormValidator.new(form).validate!

    # other stuff
  end
end
```

# Dirty Sessions w/Proxies

# Test Suites

My test suites contain multiple types of tests. They can be run in CI
or fast mode. CI mode uses real implementations (external persistence,
real caches, etc). Quick mode uses fake or in memory implementations.
This works out well because I can flesh out all class collaborations
with a very fast test suite. Then I can run the tests against real
services to make sure everything's still working.

The tests themselves are broken up into multiple categories. They all
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
repository is talking to postgresql quickly.

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
