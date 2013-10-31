---
layout: simple
title: Conference Talks for 2014
---

# Conference Talks for 2014

Hopefully you'll find me on the road this year talk about these two
things.

## Application Architecture: Boundaries, Object Roles, & Patterns

This talk is about something important in the community. The ruby
community is missing something fundamentally important. We don't know
how to architect applications. We've grown accustomed to using
frameworks for everything and we've lost our way. We no longer talk
about making applications, we speak about applications build _in_
frameworks. Example: oh hey man, did you hear NewApp123 is built _in_
rails? I take offense to that. The application is not built in rails,
it's built in _ruby_ than rails is _used_ to put it online. This
mentality is prevalent in the community. It's damaging and encourages
technical debt.

My talk is about providing a new architecture based on solid OOP
principles such as the boundary between objects, SRP, proper logic
less views, application patterns, and good testing principles. All of
this in name of changing the way we write and maintain applications.

The talk follows this format:

* Introduction
* System Design: Object roles, boundaries, protocols, patterns, and delivery mechanisms
* TDD implementation of use cases, forms, models, and other object roles
* TDD implementation of HTTP delivery mechanism using Sinatra
* Problems withs Rails & Rails style MVC approach to web applications
* The ideal stack: calling out gems that exemplify qualities mentioned earlier
* Wrap up & conclusion
* How to migrate and redesign current systems

## Application Performance & Black Magic

Why are applications slow? Well probably because you don’t have the
visibility to tell you that it’s slow. Then when you find out that it
is slow, how do you fix it? These are important questions.
Unfortunately the answer usually seems like black magic. The first
half the talk is about visibility. It highlights tools such as statsd,
ruby-prof, benchmark, and rack-mini-prof to bring visibility into all
parts of the stack. The second part is how out act on metrics and
improve the performance of ruby code as well as external services
(such as HTTP and databases). The audience should have all they need
at the end of the talk to use the scientific method to improve their
applications performance.
