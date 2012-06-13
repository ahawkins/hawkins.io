---
layout: post
title: "Defining Gems, Plugins, Railties, and Engines"
tags: [rails]
---

I listened to the Ruby Rogues [podcast](http://rubyrogues.com/048-rr-crafting-rails-applications-with-jose-valim/).
One of the people on the show asked Jose when you should use a gem,
railtie or an engine. I think that many people are unclear what defines
each and when to use them.

## Gems

A gem is a portable unit of Ruby code. It may contain `railties` or
`engines. Gems can bundle pretty much anything and do all sorts of
crazyness.

Use Cases

* You want to distrube portable units of Ruby code.

## Plugins

Plugins are an alias for Gems. However, there is another layer to this
discussion. Prior to Rails 3.2 and officialy in Rails 4 there were
things were officially called "plugins." Plugins were usually smaller
than Gems and lived inside `vendor/plugins`. Essentially no one uses
them anymore besides Heroku because they love raising deprecation errors
in current applications. You can use `rails plugin new` which will
generate a new **gem** that's connected to rails via **railties**.

Use Cases

* None

## Railties

The name itself defines its purpose. A "railtie" provides a connector
for external code to tie into Rails. It allows you do things like define
configuration for Rails or add initializers. Here are some common use
cases suggested from the Railtie docs:

* configuring a Rails framework for the application, like setting a generator
* adding `config.*` keys to the environment
* setting up a subscriber with `ActiveSupport::Notifications`
* adding rake tasks

ActiveRecord, ActionPack, ActiveSupport are all connected to rails via
railties. Railties connect separate sections of code into Rails. Here is
an real life example of a simple Railtie in the wild:

```ruby
module Cashier
  class Railtie < ::Rails::Railtie
    config.cashier = Cashier

    initializer "cashier.active_support.cache.instrumentation"
      ActiveSupport::Cache::Store.instrument = true
    end
  end
end
```

Use Cases

* Connecting non rails code to rails

## Engines

"Engines" are actually a `railtie` subclass. They can do everything a
railtie can do and more. Engines are essentially self contained rails
applications. They can have all their own models, controllers, views,
routes, and internal code. Engines can be packaged as gems. You can do
everything in an engine that you can do in your application. That's
because your Rails application is actually just an engine. You can
generate a new engine like this: `rails plugin new foo --mountable`
(Yes plugin is confusing.)

Examples:

* [Devise](https://github.com/plataformatec/devise)
* [Forem](https://github.com/radar/forem)

Use Cases

* You want make a self contained rails application that can be redistruted. 
* You want to decompose your large rails application into smaller
  components


