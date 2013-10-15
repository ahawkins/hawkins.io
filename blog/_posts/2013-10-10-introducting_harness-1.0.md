---
title: Introducing Harness 1.0
layout: post
---

Harness is one of my oldest projects. The original idea was to
forward all `ActiveSupport::Notifications` to Librato. I think it was
one of the first projects to embrace `ActiveSupport::Notifications`.
It was mentioned at Rails Conf in 2010 as an example. That was a nice
day for me to have my project on the projector and someone pointing
out the project. I felt like I'd achieved something.

A lot of things have changed since then. I've been using harness on
minor projects since the beginning. Then I put it on more
high traffic stuff. I watched Harness kill the app's performance. The
combination of counters in redis and `ActiveSupport::Notifications`
for instrumentation was not fast enough. It was time to rethink what
Harness was and what its goals were.

Previous versions had identity conflicts. It was a metric processor
and aggregator. It kept track of counters and forwarded metrics to
multiple services. Since most apps were already using redis in some
way I thought it would be safe to use redis to store counters. This
was a mistake. This created a _ton_ of write requests to redis. It
didn't scale. Harness also included the reporters. It was not optimized
for a specific use case.

Then I asked myself a question: what metrics are actually useful and
what should I do with them? Well Harness 1.0 is my answer to this
question and a stab at performance orientated developer ergonomics.

## The New Harness

Harness's primary goal is to make instrumenting your code performant
(you should not have a performance hit) and painless. It also provides
common stack metrics that everyone should be looking at.

Pre 1.0 used to calculate gauges using data it had collected. This is
no more. Harness uses statsd because it is faster and more well
maintained. If you're using statsd directly it will be easy to switch
to Harness. I've also abandon reporters because statsd already has so
many. Statsd + librato is painless. I also think statsd provides the
best instrumentation interface--counters, timers, and gauges cover all
of the use case's I've seen.

These decisions make accomplishing the second goal very easy--and
this is my favorite part of 1.0. All the common stuff is
handled for you so you can focus on application specific metrics.

I've written a bunch of plugins for all the most common gems so when
you use Harness you'll have performance dashboard waiting for you.
Dashboards require metrics, so what kind of metrics are we talking
about? `harness-rack` measures all the response times and status code.
This way you can see if your application is returning a bunch of 500s,
or what the overall speed is. `harness-activerecord` will measure all
your queries and give you an idea of what your read and write speeds
are.  `harness-actioncontroller` provides requests/second and response
time of every controller and action individually.  `harness-sidekiq`
gives you jobs/second, queue depth, and many more.
`harness-activesupport` tells you how fast your cache is and current
hit rate. There are also plugins for Varnish, HAProxy, RabbitMQ,
Redis, and Memcached. Choose the libraries that match your stack and
there you have it. You should have everything you need to analyze your
stack. If not, let open a bug and let me know what's missing.

Here's a list of everything supported at launch time:

* [ActionController](https://github.com/ahawkins/harness-actioncontroller)
* [ActionView](https://github.com/ahawkins/harness-actionview)
* [ActionMailer](https://github.com/ahawkins/harness-actionmailer)
* [ActiveRecord](https://github.com/ahawkins/harness-activerecord)
* [Sequel](https://github.com/ahawkins/harness-sequel)
* [Mongoid](https://github.com/ahawkins/harness-moped)
* [Redis](https://github.com/ahawkins/harness-redis)
* [Sidekiq](https://github.com/ahawkins/harness-sidekiq)
* [ActiveModel::Serializers](https://github.com/ahawkins/harness-active_model_serializers)
* [Varnish](https://github.com/ahawkins/harness-varnish)
* [HAProxy](https://github.com/ahawkins/harness-haproxy)
* [Memcached](https://github.com/ahawkins/harness-memcached)
* [RabbitMQ](https://github.com/ahawkins/harness-rabbitmq)

Writing your own is easy. Check the links to see how it's done.

Instrumenting code is easy. `$statsd` global is no more. Include
`Harness::Instrumentation` in your class and you're off to the races.

Metric logging happens in a separate thread so the main
thread is never blocked.

That pretty much sums it up for the new Harness. I hope harness helps
you gain visibility into your apps and ultimately make them faster.
