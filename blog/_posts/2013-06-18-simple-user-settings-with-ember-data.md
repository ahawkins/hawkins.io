---
title: Simple User Settings with Ember Data
layout: post
segment: ember
---

Your application needs user settings. You need to persist some sort of
structured data that decides how the application should function. This
is a common use case. Ember-Data (shockingly depending on who you are)
makes this easy.

Here are some assumptions:

* You have `POST /settings` as well as `GET` and `PUT`
  routes.
* The server just saves whatever data is sent w/o any processing or
  other handling.
* There may be any number of complex objects representing settings.

It's easy to begin. Create a simple settings object that subclasses
`DS.Model`:

```coffeescript
App.Settings = DS.Model.extend
  # any settings you want go here
  startPage: DS.attr('string')
  logOutAfter: DS.attr('number')
```

Now it's time to do some quick hacks. ED does not support singular
resources easily right now. A simple workaround is to make the API
accept an `:id` parameter and ignore it. So if you can, change the
URL to something like `GET /settings/:user_id` and ignore the
`user_id` param on the server.

You can retrieve the settings by doing `App.Settings.find('me')`. The
`me` part is kind of a hack. It's just a fake ID used to hit the right
URL. Now at this point we can interact with whatever you need an
simply save the object by calling `commit()`.

Let's say a new requirement comes in. You need to create some complex
objects in the settings. Assume you need to specify an array of
defaults. The question is, how can I make ED send the data I want
given an arrangement of model objects? Well if you want to send an
array of objects with the settings, then you must embed them. So we go
ahead and create an `App.DefaultTask` as an example.

```coffeescript
App.DefaultTask = DS.Model.extend
  type: DS.attr('string')
  importance: DS.attr('number')
```

Now comes in important bit. You must configure a mapping in the
adapter to embed the default tasks in the settings. The proper
associations must be setup as well. This means a 1-many association
between `App.Settings` and `App.DefaultTask`.

```coffeescript
App.Adapter = DS.RESTAdatper.extend()
App.Adapter.configure App.Settings,
  defaultTasks: { embedded: 'always' }

App.Store = DS.Store.extend
  adapter: App.RESTAdapter

App.Settings = DS.Model.extend
  # original code
  defaultTasks: DS.hasMany('App.DefaultTask')

App.DefaultTask = DS.Model.extend
  # original code
  settings: DS.belongsTo('App.Settings')
```

Now the setting hash sent to the server will contain all the default
tasks along with their attributes. You can use the same strategy for a
one to one association. This technique is perfect for building up
complex objects on the client and persisting them on the server. The
embedded associations ensure everything is sent and one request. You
are also able to work with full `Ember.Object` instances meaning you
get all the data binding and dirty tracking goodness. This works
perfectly when the underlying store is dumb because you can serialize
whatever you want and ED will load it right back up again.
