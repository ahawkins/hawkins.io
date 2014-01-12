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
