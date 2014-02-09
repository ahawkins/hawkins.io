---
title: "Introducing Chassis"
layout: post
---

The last posts on my blog have been about what I consider good design.
I arrived there after months of work in multiple projects. I think
they work. I've been collecting and standardizing the code in a new
project. This project is called
[chassis](https://github.com/ahawkins/chassis). Chassis is not a
framework by any means. It is simply a collection of modules, classes,
and enhancements you can use to build applications.

Chassis contains everything you need to build a loosely coupled
application. It's built using specifically chosen gems. All gems have
been evaluated on their code and extendability. There are no gems with
C-extensions. All the code is implementation agnostic. Each gem has
minimal or no dependencies, if a gem has dependencies, they are
undergo the same scrunity.

Chassis builds an ideal stack for building web applications. You
shouldn't really need any other gems to construct an application.

Chassis builds on the following products:

* Sinatra w/extra middleware & helpers for building web applications
* Manifold - For CORS. `enable :cors` in `Chassis::WebService`
* Prox - A completely transparent object proxy. Perfect for decorating
  objects
* Harness - Portable and exendable application performance library
* harness-rack - All requests to `Chassis::WebService` are tracked for
  performance
* Virtus - for building form objects
* Faraday - w/extra middleware for outgoing HTTP
* logger-better - make the stdlib logger more useful and provide a
  null implementation.

The project also contains multiple utitlity classes and other
refinements to the standard library. I suggest you check it out.

I haven't released an official version because it's still changing
rapidly. I plan to release a version `0.1.0` in the coming months.
Chassis will be featured in my screencast on [application
architecture](http://rethinkapplicationarchitecture.com).
