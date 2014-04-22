---
title: "Working with Repositories"
layout: post
---

I've gotten a ton of excellent feedback and questions about the joy of
design series. Thanks for all of that! I recently spoke at at
Wroclove.rb about the topic. You can read my
[talk](/2014/03/rethinking-application-architecture-talk) if you need
a referesher. I strongly recommend developers use the repository
pattern in their applications. Many people approached me after the
talk and wanted to know more. There was so many excellent questions
that I could not address them in verbal form. So I set out to create a
series of posts describing all I know about working with and
implementing repositories.

This series is an appendix to the [joy of
design](/2014/01/rediscovering-the-joy-of-design/) series. The
repository pattern has changed how I approach writing software. In the
beginning of my career I was a horrible programmer. I'm not perfect
now, but I'm a hell of a lot better. I wrote my own little MySQL
adapter for my php apps so I could query the DB wherever I wanted to.
Then came Rails with its wonderfully power implementation of the
Active Record pattern. Rail's ActiveRecord made me realized the power
of abstractions over data. Gone where the day of sanitizing forms and
writing SQL. Things had leveled up. But something was missing. There
was never any true single responsibility. Every application was working
under the assumption that a model is data plus persistence. Rails only
made that worse and has probably scared many people for life. The
repository pattern is the anti-active record pattern. It enforces true
separation of concerns by design. It encourages to separate how you
think of your objects. It is a decoupled state of mind. Once you enter
this zen state you cannot go back.

The repository pattern is not a silver bullet. Proper use will make
your software's architecture more sound, but it will not write your
application for you. One simply cannot just "use" a repository as
you'll come to see through this series of posts. I haven't found a
good implementation in Ruby so I worte my own inside
[Chassis](https://github.com/ahawkins/chassis). All the posts assume
this implementation, so these posts also serve as some documentation
for people interesting in using the library. I hope by the end of
these posts you'll see and understand how easy it is to write an
application specific persistence layer. Check back in a day or two for
the first entry on why and when to choose this architecture. Until
then the Joy of Design post on [Repositories, Queries, &
Persistence](/2014/01/pesistence_with_repository_and_query_patterns/)
is your homework.

Here's the Schedule:

1. [When & Why Repository](/2014/04/repositories-when-and-why/)
2. [Chassis Internals](/2014/04/repositories-chassis-internals/)
2. [The Public Interface](/2014/04/repositories-the-public-interface/)
3. [Implementing Queries](/2014/04/repositoreis-implementing-queries/)
4. Loading Object Graphs
5. Implementing Adapters
6. Class Specific Persistence Concerns
7. Application & Repository Tests
