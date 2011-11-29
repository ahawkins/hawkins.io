---
layout: post
title: Moving on from Rails
tags: [rails]
---

I've been doing Rails since 2006. My skill level and the framework
as changed greatly since. I came from PHP web sites and Java through
academics. Ruby was breath of fresh air. Rails was a thing a of beauty.
It was exactly what I needed at the time. Now times are different.

## A Changing Web Yields Changing Requirements

Web developers know there is an _incredibly_ high turnover rate in
technologies. Think about to 6 months ago. Did you know about
Coffeescript? What about backbone.js? What about websockets/push? Not all
of those things are technologies. Coffeescript is not a technology, it's
just a nice layer on top of Javascript. It is not a new technology like
HTML5 Websockets. Socket based communications are not new by any means,
but they are new for us since we can use them in the browser. 

Did you also notice how all the things I rattled off were purely related
to JavaScript? This isn't a purely server side driven game anymore. The
paradigm is shifting in how we architect modern internet applications.
Before we got to where we are now we have to know where we came from.

I was coming from PHP. PHP was shit then and is still shit now. I just
I think this is a common story for many Rails guys.
I didn't realize how shitty PHP as _language_ was until I started learning
Ruby through Rails. At the time, Rails was exactly what many devs
wanted. It made common tasks like generating basic CRUD interfaces. You
could simply scaffold and start building (but I never recommend that),
but you _could_ do it. It made managing a DB easy. There was
`schema.rb`. There were ActiveRecord associations. ActionController and
AJAX handling. It did everything and it made a huge splash in the
industry. Rails made such a big impact it was able to drive the growth
of 37signals into a major powerhouse. There are hundreds of committers
and the framework is still very popular and useful. It made building Web
2.0 quick and easy. Hell, the generated application greets you with:
"you're riding on Rails."

I look back on those days fondly. It was a much more simple time. The
barrier to enter the market was low. You could churn out SaaS services
so quickly. Generate a rails app, throw up some scaffolds, and boom.
There ya go. Zero to sixty faster than an R8. Now things are different. 

Think back to when Rails first came out. There was no iPhone. There was
no Android. People still owned Nokias and actually bought stock in the
damn company. Windows XP was still massively popular and we were
**fighting** to get a decent version of IE (but that will never end).
There was no such thing as a mobile web. No one was thinking about
tablets. How old is the iPad? Not very old. The web has drastically
changed due to the smartphone explosion. This is only the first step in
a true multiplatform internet. A few years ago you could get by with
having a mobile version of your web app. Now that's not enough. That
concept is almost laughable today. The bar is set pretty high. People
expect applications for different devices. This is unfortunately our
fault since we've trained them. I was just on
[lemon.com](http://www.lemon.com) while showing it to my boss. There is
a huge picture of numerous devices. People are off their computers now.
Now it's simply not enough to build a web application. You need to build
a service. You need to build your own platform to build your own
applications off of. You will not survive if you don't. The
changing web yields new requirements in how we design and structure
modern applications.

## SoA Platforms then Applications

Service oriented architecture has always been very fascinating concept.
Jeff Bezos was way ahead of his time when he basically pulled a Hitler
and dictated that everything would switch over to SoA. We are at point
in the web where platforms represent core business value. You need to
have a platform that's accessible on any device either natively or with
a browser. So now you're faced with a question. How can you develop your
platform and expose to different devices: HTTP. I like HTTP and I make
my platforms speak HTTP. We can use HTTP to create JS applications for
browsers. We can also use HTTP to communicate with an external system
through OS level code. You can build a native application on Android
backed by an HTTP service. You can build your JS application backed by
HTTP. Don't think that the browser is the only answer. Not every single
application can exist in the browser. What if you need to write files?
What if you need to access hardware? The browser is not the be-all & end
all of internet applications. People will always be creating native
applications. So don't look at everything purely through the: HTML5 and
JS lens. Sometimes applications need more.

I think many developers are realizing this. You can see it
with things like Sproutcore (much love to SC) and Backbone. Less so than
backbone and more so with SC < 2. There is this revolution in MVC on the
client. Ya, you could call it that, but really it's the beginning of a
wall being built between clients and servers. Backbone is becoming
increasingly popular for good reasons. It allows developers to make
javascript applications with nice MVC trimmings. But it's more than
that. It makes people structure and organize their javascript as an
application, and not simply a hodepodge of event bindings and AJAX
related trickery. Applications are now being built in Javascript. This
trend will only continue. Why? Because the interfaces are fucking fast.
Things happen on the user's computer and can be persisted back to the
server later. Hell, Sproutcore even abstracted HTTP persistence
completely out of the framework. There is a clear separation of concerns. The
platform processes data and serves up JSON. Then end programs actually
do all the "work" by presenting UI's and all that good stuff. And now
you've built the first consumer for your platform. With Sproutcore you
may even build the entire application without even conntecting it to a
server. At that point, you're able to treat persistence as an
implementation detail which drastically changes the way you think.

## HTTP Backed Services

HTTP backed services are inherently easy to write and manage. They are
much easier to write than traditional web applications because you do
not have to worry about V--just MC. From my experience, generating a
good UI (V) takes orders of magnitude more than implementing M and C. HTTP is
perfect because you only have to worry about garbage in and garbage out.
In Rails, this means you really only care about `params` and
`respond_with`. Data in and data out. Now, when I look at these API'S I
look at the responsibility to the end developer: return JSON. That is it.
A single focus: return JSON. Of course there is processing involved but
the main point is return JSON that end application can use for it's own
purposes. That makes developing this very easy because it removes many
other requirement and makes you think about a fundamental thing: HTTP is
only how the outside talks to my code. My application is not HTTP and
it's certainly not just HTML and JSON. This is only how I talk to the
outside world. The code can be something totally different. You could
have nginx talking to a haskell application. No one cares as long as the
parameters and data coming out are according to spec. This has been
extremely freeing for me because I no longer think **rails is my
application.**

## Changing How We Code

Avdi Grimm verbalized some of my current feelings in this regard. His
object on Rails paper goes through the entire process of creating a blog
using OOP techniques. The code is developed completely outside of Rails.
Rails isn't even introduced. Models are derived completely on their own.
Collaborators and responsibilities are defined as well. Slowly the system
takes shape. First you need ActiveModel for some validations. Everything
is going well. Eventually you're going to need persistence. He treats
**persistance** as an implementation details Mdoels are more than
ActiveRecord! Your code is more than Rails. Rails is not your code. You
can and **should** develop the business logic completely on your own
ISOLATED from whatever code you'll eventually use to allow the outside
world to consume your service. Corey Haines started something called
fast tests. Fast tests are great. Everyone loves them. They make tdd
faster blah blah. His essential point was to move code out of Rails into
Ruby modules that can be tested in isolation. This is a step in the
right direction but I think it's a very small one. You should go all out
and simply move your code out of _whatever_ framework you're eventually
going to use. I highly recommend Avdi's paper on 
[Objects on Rails](http://avdi.org/devblog/2011/11/15/early-access-beta-of-objects-on-rails-now-available-2/)
to see a very refreshing approach. The continuing theme here is
dividing parts of your eventual platform. Most important is splitting
access from application.

## Moving Away From Rails

Rails has always been fantastic at one thing: accepting, handling, and
returning body for a HTTP response. What you choose to put that body has
always been up to you. Just recently, it's been assumed you're going to
generate HTML. Now I just want to generate JSON. Designing my HTTP based
services only require two things:

1. Accept http requests
2. Give me a nice API for determine response code and response body.

Rails has always been fantastic at those two things. But now, I do the
rest. I'm not really worried about ActiveRecord. Let me handle the
models. I don't need ActionView. There are a lot of things I don't need
from Rails anymore. I think that's good. What makes Rails 3 great is you
can modularize it by removing (or including) components. Now I can get the most
out of Rails by making it fit my requirements. But that's it. I no
longer think Rails is my application. It's just a nice thing for
handling how it's accessed.

## Moving on in Life

I've become increasingly disinterested with Rails over the past while.
This is nothing to do with the framework itself. It's just no longer
related to my core interests. A few years ago, it was my only interest.
It was simply how you build web applications. That time has come and
gone. Now we are faced with applications with more diverse requirements.
You may have a Rails based application for handling the majority of web
requests working in conjunction with a Node process for evented stuff.
Hell, you may at some point even have processes in different languages
which have been optimized for different things. Look at Twitter with
Scala. There are many permutations of different technologies for different
requirements. There will be more permutation as the way we architect the
modern web. For me, and I think many others, Rails will become and
increasingly smaller piece of the puzzle. Why? Simply because their
platform is more than Rails. Now I focus on other questions. Rails
answers some of them, however I'm finding it's the answer less and less.
