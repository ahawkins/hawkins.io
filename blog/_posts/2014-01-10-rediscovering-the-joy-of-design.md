---
title: Rediscovering the Joy of Design
layout: post
---

The last year and half have been very interesting. It has been a
transitionary time. My approach to software design, maintainability,
and implementation has radically changed. The changes have been so
beneficial that I can not go back. That path only leads to anger,
anger leads to hate, and hate leads to the dark side. This is a post
about going to the dark side in some way. In my opinion, my approaches
are controversial. They are controversial because so many Ruby
programmers have been spoon fed coupling and destructive programming
choices since they got into the language. I've shown people my
techniques and have been met with somewhat visceral reactions: "What
is this?", "Why are they are so many classes?", "Why don't you just
use \_insert gem here\_?" These are honest questions but the reactions
are more interesting. Some people are offended. It's a shame that the
design triggers these reactions. On the other hand it's wonderful
because something is working. Ideas are being challenged and people
are beginning to think differently (if not for a moment).

Undoubtedly I am not the first person utilize design patterns and
boundaries. I'm sure there are thousands of posts just like this.
Some lessons are best learned through first hand experience. You can
read about design patterns and boundaries until you're blue in the
face but you can never fully comprehend the pain they prevent until
you've spilled your blood over a code base.

I'm a web programmer exclusively. I prefer working on JSON APIs but
I've also worked on (from what I can see the biggest Ember.js app)
[Radium CRM](http://radiumcrm.com). I've be doing some user facing
work since starting a new full time job. However writing web services
or libraries is 90% of the work. I was doing traditional rails
applications before all this. I enjoyed it at the time. When I started
work exclusively on APIs I realized this was better. Why? The answer
is simple.

Boundaries. All good design enforces strict separation of concern
though boundaries. Boundaries are boxes that encourage design through
protocols. What actually created the boundary? The internet itself.
When you design a web service, you approach it from the client or
server side. There is only one thing: the data sent between each.
There is nothing else. This was so liberating. This started a chain
reaction and everything changed. I began approach every aspect of the
application from a different perspective.

The knowledge cannot be summed up in one post.  I decided to approach
this problem in a different medium. I took my first stab at writing a
technical "paper." I say paper loosely. The paper itself should be
professional, easy to read, on point, and highly informative. It's
clocking in around 20,000 words when it's all said and done. I was
lucky enough to recruit some people to review it. Avdi Grimm was
gracious enough to lend his time. Lucky for me because I respect the
hell out of guy. One of his comments hit home:

> I haven't even reached the need for Repository and Query yet, and
> I've already experienced major design epiphanies. If there's a point
> to all this, it's this: consider not glossing over the building
> blocks that go underneath Repository. Not every app needs a
> repository (some don't even need Mapper). And every single layer of
> the cake, if approached mindfully and intentionally, can bring
> serious benefits.

Continuously layering design patterns changes everything. It did for
me. This post is the first in a series on how I structure and write my
applications. Each part will focus on a particular role.
Check back in a day or two for the first entry on delivery mechanisms.

Here's the schedule:

1. [Delivery Mechanisms with Sinatra -
   Middleware](/2014/01/delivery_mechanisms_with_sinatra_middleware/)
2. [Delivery Mechanisms with Sinatra - Helpers & Error
   Handling](/2014/01/delivery_mechanisms-helpers_and_error_handling/)
3. [Delivery Mechanisms with Sinatra - Route 
   Handlers](/2014/01/delivery_mechanisms_with_sinatra-route-handlers/)
4. [Delivery Mechanisms with Sinatra - Logic-less
   Views](/2014/01/delivery_mechanisms_with_sinatra-logic-less_views/)
5. [Delivery Mechanisms with Sinatra - Composing Web
   Services](/2014/01/delivery_mechanisms_with_sinatra-composing_web_services/)
6. [Delivery Mechanisms with Sinatra -
   Testing](/2014/01/delivery_mechanisms_with_sinatra-testing)
7. [From Objects With Virtus](/2014/01/form_objects_with_virtus/)
2. Forms with Virtus
3. Use Cases
4. Business Objects & Persistence

If you're already interested you can check out the
[paper](https://github.com/ahawkins/hawkins.io/pull/7). Everything is
covered there in much detail. In the meantime **pretty please** ask me
to pair with you if you want to explore this sort of stuff in your
applications. Hopefully you'll see me at some conferences this year
talking about this stuff. Tweet me if you have something to say!
