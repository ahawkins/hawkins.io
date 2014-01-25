---
title: "The Joy of Finishing Design"
layout: post
---

This is the last post in the series. I've covered a lot of ground in
all the posts. Here's a review:

* Delivery mechanisms with Sinatra. It's awesome. Use it.
* Form objects with Virtus.
* Implementating functionality through use cases.
* Writing entities
* Separation objects from persistence with the repository pattern
  pattern.

That's the high level summary. I've tried to pass on some low level
knowledge along the way. I've been using this architecture for a while
now. I actually just started another big project as well. I know it
will pay huge dividends there. All of these ideas are works in
progress. Nothing is final. I constantly question all the design
decisions and wonder how the entire system can interact better. I
presented these techniques because they haven't failed me on small or
large applications. Who knows, maybe you'll see another post a year
from now titled "The Joy of Redesign."

Many of you are probably thinking about redesign or how to refactor
your existing applications. Here's some advice: work from the outside
in. Start with the delivery mechanism. Create view models, then form
objects. Next extract use cases. Refactor data calls to use defined
query type methods. Then replace with a repository. Whatever you do
start by creating boundaries and interfaces. Isolate concerns and
create layers. Boundaries will change everything. Use them and the
code will improve.

I hope you enjoyed this series. It has been a joy to write and share my
ideas with the world. I'd love to talk to you about how you can
refactor your application or if you have questions implementating any
of this stuff. Don't hesitate to pair either. It's a great way to
learn. Good luck out there.
