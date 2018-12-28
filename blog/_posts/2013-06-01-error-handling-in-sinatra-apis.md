---
layout: post
title: "Error Handling in Sinatra APIs"
tags: [ruby, sinatra, api]
---

I'm constructing an API for an Ember-Data backed application. This
creates one important requirement: every communication must happen
over JSON. This includes happy path and non-happy path responses.
201's must be treated the same way as 500's. The sinatra app is set to
handle a specific set of exceptions. There are not failures, but
exceptions raise with the sole purpose of catching them. These include
errors like `RecordNotFound`, `ValidationError`, or
`PermissionDenied`. Then there are the unexpected errors--the actual
exceptions that break things. These handling these turned out to be
problematic.

Exceptions could happen in two places: inside the application or
inside middleware. Exceptions inside the app were useful. I'd start
the server with `rackup` and see a stack trace in `$stdout`. The
server would correctly respond with 500. Errors from inside the
middleware stack would simply return a 500 without anything on
`$stdout`. This had something to do with sinatra's internals. I'm not
sure if it's a bug or a feature. I've opened an [issue](https://github.com/sinatra/sinatra/issues/721)
on github about this.

With those things in mind, I set out to come up with a solution for
these requirements:

* Exceptions coming from the app or middleware are logged to the
  console
* Exceptions coming from the app or middleware are rendered as JSON in
  a helpful format. The stacktrace is included in the development
  env.
* Completely ignore Rack's default `ShowExceptions` middleware. This
  causes HTML responses useless when debugging the API.
* Run simply with `rackup`

It took a couple of hours to come up with something that handled all
these cases. I went back and forth about how the Sinatra app should it
work. I settled with the app only catching the exceptions it expected.
The rest would continue up the stack. Exceptions coming from
middleware would already propagate up the stack anyways. All I had to
do was implement a simple middleware to catch exceptions and render
them as JSON. This can all be encapsulated as a simple `config.ru` and
switching some settings in the sinatra app.

<script src="https://gist.github.com/ahawkins/5686180.js"></script>

With that, all errors will be logged to the console and rendered
as pretty JSON making it easy for all clients to use.
