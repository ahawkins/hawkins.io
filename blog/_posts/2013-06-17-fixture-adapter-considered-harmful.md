---
title: DS.Fixture Adapter Considered Harmful
layout: post
---

We've been using Ember-Data for quite a long time on Radium. We've
also been prototyping our main application for a long time. We were
not exactly sure what we wanted the application to look. We did have a
general idea of what the data model would look like. Here's the
question we faced early on: *do we connect to a server right away or
use the fixture adapter for some stub data?* I decided it was best to
simply use `DS.FixtureAdapter`. I made this decision because, in
theory, we should simply be able to switch over to `DS.RESTAdapter`
when the time is right. This decision was made probably almost 1.5
years ago. Since then we've gone through many versions as we finally
came to idea of how the user facing application should behave. The
ember app was simply using local data the whole time. It would not
have been possible for us to do this if we had been bound to an API at
the same time.

Fast-forward to 2 or 3 weeks ago. The application was basically
complete and working as intended. The time had come to hook it up to a
server. I didn't expect the process to go smooth. My coworker and I
simply planned on working through every failure and essentially
beating on the damn thing until it worked. Getting it to work has been
a real pain.

There are a few core issues.

1. ED is still [alpha software](/2013/05/ember-data-is-pre-alpha-software/)
2. Adapter semantics are not consistent.
3. Adapter has varying levels of functionality.

The semantics are a real issue. If the API embeds records, then you
better make **damn sure** you embed them when using
`DS.FixtureAdapter`. This causes a major problem when dealing with
dirty records. Changing how records are embedded changes which records
are dirty. That will completely ruin your application some cases
because will not be able to save changes or handle UI events
correctly. This is the single biggest issue for us.
[@dagda1](http://twitter.com/dagda1) spent a week simply updating
inline editors to handle this.

`DS.FixtureAdapter` does not use promises. This is a fun fact that can
make your application behave differently. `DS.FixtureAdapter` does not
implement the error and invalid handling out of the box. You have to
do this, but it can make it hard to test the full range of application
functionality. Also, the fixture adapter is not *as* async as the
real world. It uses a very short delay of 50ms. This is not enough to
get a feel for the application would behave in the real world. It is
also short enough to hide some run loop issues.

Hindsight is always 20/20. I can't stay 100% that I regret the
decision to use the fixture adapter for prototyping and development. I
can inform you, the interested party, with knowledge that will help
you make the best decision on your project. That being said, I **do
not recommend** you use `DS.FixtureAdapter` for prototyping.  If you
are simply learning ember then by all means use the fixture adapter.
It will give you enough runway to get off the ground and mess with
things. It is perfect for this case. If you intend to deploy
something, then I **recommend you get started with the REST Adapter**
as soon as possible. However, this does not mean you have to commit to
an API. Simply create a dumb server that stores what the client sends
it. Once you are familiar with the application's semantics, then you
can build the underlying API. If you think you know what you're doing
and still want to go ahead with `DS.FixtureAdapater`. Then here are
some tips:

1. Set the latency to something much higher and expected. Say 300-400
   ms.
2. If you know that records should be embedded, but sure to map them
   as embedded in the fixture adapter.
3. Subclass `DS.FixtureAdpater` and implement some sort of failure and
   error handling. You could have the adapter fail 10% of the time.
   This is like a chaos monkey and can be a great stress test for your
   app.
4. Run tests using `DS.RESTAdapter` and `DS.FixtureAdapter`.

I think this is a very unfortunate situation. Ember-Data is an
implementation of the data mapper pattern. The pattern promises you
should be able to switch between adapters easily. If that's not
possible then we have some work to do. I'm working on correcting these
issues and making it easier for developers. I think the future goal is
to develop and test with fixtures/in memory data and deploy with the
`DS.RESTAdapter`. We still have a long way to go. I hope this post
helps you make a more informed decision on how to proceed in your
project.
