---
layout: post
title: "Rails 3.2, Heroku, & rails_log_stdout"
tags: [rails]
---

I try to keep my applications on the bleeding edge of Rails. After being
stuck Rails 2 for almost 1.5 years after Rails 3 was released, it's been
very nice. Of course the bleeding edge has it's drawbacks. Enter Rails
3.2.0rc2 and Heroku. `vendor/plugins` is deprecated in Rails 3.2. Heroku
dumps it's configuration plugins into `vendor/`. This gives you a nice
deprecration warning everytime a rails environment process starts.

I had to do some debugging with developers using the API. This means I
need to be able to see what their applications are sending in realtime.
I've been using Heroku for a long time, so I just fire up `heroku logs
--tail` and watch away. Except, now with rails 3.2.0rc2 I don't see
anything coming from rails. Only the start up messages and the request
accepted message. Well, there is no parameter information. 

    2012-01-16T13:26:50+00:00 app[web.1]: Started POST "/todos" for 82.181.188.119 at 2012-01-16 13:26:50 +0000
    2012-01-16T13:26:51+00:00 heroku[router]: POST api.radiumcrm.com/todos dyno=web.1 queue=0 wait=0ms service=212ms status=422 bytes=92

Well shit. That doesn't really tell me anything at all. I want to see
this: 

    2012-01-16T13:26:50+00:00 app[web.1]: Started POST "/todos" for 82.181.188.119 at 2012-01-16 13:26:50 +0000
    2012-01-16T13:26:50+00:00 app[web.1]: Processing by TodosController#create as JSON
    2012-01-16T13:26:50+00:00 app[web.1]:   Parameters: {"todo"=>{"kind"=>"call", "finish_by"=>"2012-05-01T18:52Z"}}
    2012-01-16T13:26:51+00:00 app[web.1]: Completed 422 Unprocessable Entity in 208ms (Views: 0.3ms | ActiveRecord: 110.7ms)
    2012-01-16T13:26:51+00:00 app[web.1]: cache: [POST /todos] invalidate, pass
    2012-01-16T13:26:51+00:00 heroku[router]: POST api.radiumcrm.com/todos dyno=web.1 queue=0 wait=0ms service=212ms status=422 bytes=92

Turns out there is problem with the `[rails_log_stdout](https://github.com/ddollar/rails_log_stdout)`
plugin heroku uses do it's business. The rails initialization process
has changed slightly. `ActionController::Base.logger` was being
assisigned to the standard `log/production.log` file somewhere before
the std out logger was being set. Then through the magic of `||=` it is
already defined and not reassigned to the stdout logger. The plugin is
one `init.rb` file which is now deprecated. Time to fix this!

I wrote a simple rails engine (rails 3+ only!) to fix this and stop the
deprecation warnings. Hopefully heroku will use this code to make their
platform rails 3.2 compatible. You can grab the code [here](https://github.com/adman65/rails_log_stdout).

Then stick this bad boy in your Gemfile:

    group :production do
      gem 'rails_log_stdout', :git => 'git://github.com/Adman65/rails_log_stdout.git'
    end

Now you have **also** have to tell Rails to explicitly load a whitelist
of plugins. You can do this in `production.rb`

    config.plugins = [ :rails_serve_static_assets ] # ONLY load static assets plugin

You'll still see depreaction warnings because heroku is
injecting code into your source, but logging will work as you expect. If
you are using any other plugins make sure you add them to the list.

Happy log tailing!
