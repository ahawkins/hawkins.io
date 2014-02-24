---
title: "Rails Needs an After Fork Hook"
layout: post
---

I don't write about Rails anymore. I don't use it in my personal
projects. However I get daily exposure at the office.  We use AMQP.
AMQP is awesome but depending on how your client it has initialization
requirements. We're using the `amqp` gem which is based on
eventmachine. So depending on how & when the application is booted we connect
to AMQP in different ways. This problem also gets worse because our
rails application boots in different contexts. There are:

* from unicorn (preforking-nonblocking)
* resque (forking-nonblocking)
* rake tasks (single thread-nonblocking)
* console (single thread-nonblocking)

Also the AMQP connection needs to happen at different points in the
boot process. In forking process the connection is made after fork. In
single processes the connection can be made during the initialization
process. I took care of the rake task an console uses cases by using a
rake initializer and a console hook through a railtie. I cannot take
care of the `after_fork` cases with a railtie. Rails can actually do
something about this.

Rails is popular enough that popular projects provide integration (via a
railtie). Forking web servers (unicorn/passenger) are not going away
anytime soon. Resque is not going away either. There are plenty of
popular projects that need this hook. I think Rails should add an
`after_fork` hook to the `Railtie` class. This make it easier for any
project or application requirement to tie into the boot process and
execute code in a clean way. This would require two interfaces: one to
declare hooks, and one to run the hooks. Here is my proposal:

```ruby
class AMQPProject < Rails::Railtie
  # takes an argument like initializer to `after` and `before`
  # options work as well.
  after_fork 'amqp.connect' do
    AMQPBootstrapper.connect
  end
end
```

`ActiveRecord::Railtie` can register its `after_fork` handler to
reconnect. Then everyone can remove that line from all their projects.

```ruby
module ActiveRecord
  class Railtie < ::Rails::Railtie
    after_fork 'active_record.connect' do
      ActiveReord::Base.connect
    end
  end
end
```

Now on the project side you'd simply call `Rails.application.forked`
to run the hooks.

```ruby
module Resque
  class << self
    def boot
      # do stuff
      fork do
        ::Rails.application.forked if defined? ::Rails
      end
    end
  end
end
```

I think this would benefit the community and keep the framework
up-to-date with how it's used in the real world. What do you think?
