---
layout: post
title: Moving on from Rails
tags: [rails]
---

I've been doing Rails since 2006. It's come along way since then. I was
really looking forward to Rails 3.1. I thought it was going to be the
shit! But now I have different opinions.

## How I Came to Love Rails.

Rails sloved _all_ my problems when I started doing Rails coming from
PHP. It was a full stack framework. It handled templates, mapping URLS
to code, and persiting records to the databases. It even did all that
complicated AJAX and JS stuff that has been demoed about as many times
as the gem itself has been downloaded. And scaffolding. Dear god
scaffolding. How many times have you needed to write all that CRUD for
all your web apps? Every. Fucking. Time. Rails just made everything so
simple. It made writing web applications for that era so nice. It was
nice because I didn't actually create anything complicated. All I
created where little bullshit applications. The kind you could string
together in a week or two without having to worry about. It was a more
simple time back then. The web hadn't progressed into what it is now.
There was no Android. There was no such thing as mobile browsers. Hell,
the god damn _iphone_ hadn't even come out yet--people still bought
Nokia phones. There wasn't this "experience everwhere" concept. Even
that took a while to catch on. But here we are now. The architecture of
developing web based applications has changed. My problems have changed.
Now I need different tools.

## Changing the Guard

If you want to develop anything serious these days you need to consider
these factors:

  1. A web application
  2. An Android application
  3. An iPhone application
  4. Tablets

Now that you have to develop your "web" application for many different
platforms, you're not really developing a web application. You're
developing a web **backed** application. These are inherently different
things. Back in the day, you had your website. And that was it. It used
some AJAX and it got the job done. Now the entire market as moved to
place where it is not longer enough to develop a web application. You
need to develop your own **platform.** This platform should be able good
enough to build any client application on top of, be it a web
application, android, or any other client application. All these clients
can communicate over HTTP. Your platform essentially becomes an HTTP
based API. This is a suprisingly nice thing in retrospect. It removes
complexity from your platform because all it does is **return JSON.**
This is only reponsiblity of modern platforms. And you can hack together
really quickly with `respond_to :json ; respond_with @resources`.
(Although I don't recommend that at all). They no longer generate views,
matter a fact ActionView is completely removed from modern platforms
(unless you need ActionMailer which uses it for mail rendering). For me
personally, the templating system really interested me in the beginning.
Now I don't even use it. There is no point. A modern web based SaaS is
going to have a HTTP backend for it's single page JS frontend and all
the other clients. All those clients actually render views with the data
the backend delivers. There goes the (traditional) V in MV. The way we
do M these days is completely different. 

## Standing on Your Own Two Feet: I don't need ActiveRecord

ActiveRecord was completely stunning in 2006. I don't rely on as much I
used to. Now I only think of it has "data persistance." You can persist
data in a variety of different ways. You can use Mongo or if you're
crazy enough, you can even use Redis. I've reached a point where I only
use the mosic basic ActiveRecord operations, it no longer impresses like
it once did. I find that Mongoid is much more flexible for nonrelational
data and is much less intrusive. Now I think in ActiveModel. ActiveModel
is fantastic. I love ActiveModel. It lets you treat persistance as an
implementation detail. Yay OOP. This is Rails 3 at it's finest. Rails 3
makes coding modern OOP HTTP based platforms so nice because you can
actually swap out stuff you don't need. Which makes me think about what
I actually need Rails to do. 

## Rail's Reponsiblity

The responsiblity is single and focused. **Respond to HTTP requests.**
This means:

  1. Map URL's to Code
  2. Provide me a nice interface for working with requests
  3. Middleware is a plus
  4. Make it easy for me to return structured data.

All I want is for it to be easy to return JSON. That's all the HTTP has
to do. ActionPack is **fantastic** for this. `params` is the best thing
ever. Using all the filtering method makes respond to specific requests
a dream. `respond_with` is nice because it gives me a hacky way to just
jsonify all things. That is all I want. I don't want views. I don't want
model. I don't want mailers. I really don't want much. I think that my
use case is Rail's best functionality. Handling HTTP feels like the most
developed part of the framework. Now people get lost in ActiveRecord and
ActionView. They are more concerned with generating view and their
schema. Then there is the asset pipeline. Oh the asset pipeline. I don't
think anything has ever divided Rails developers like the asset
pipeline. You either love it or hate it. Initially I loved it. I thought
it was a fantastic idea. I agreed that making assets first class
citizens in rails was a smart move. However, now I find the asset
pipeline to be a completely worthless functionality. Serving assets (or
compiling assets) has nothing to do with HTTP API's. This makes
absolutely no sense! There is no reason to concern yourself with this.
This is a different program's responsbility. Creating a platform allows
individual programs to concern themsleves with only themselves. A single
page JS application is just that: a single js file. Do you need a
fullstack web framework to serve that (or even be involved with that)? I
think not. The asset pipeline is creeping into a sphere of responbility
it should not go into. API's don't serve assets and really, they don't
give a fuck about them anywhere. There is the flip side of this coin.
Not everyone is using this type of architecture. I used the asset
pipeline to whip up my personal travel site:
[ISOS](http://isos.broadcastingadam.com). It was a truly nice
experience. It made building that little bullshit site pretty
easy--matter of fact it was enjoyable! But there is no way I mess with
the asset pipeline for my enterprise work. It is completely outside the
sphere of concern, hell, a lot of things bundled with the framework are
outside my sphere of concern.

## Everything I don't need, I can Remove

This is why I still use Rails. I don't need ActiveRecord. Uncomment the
Railtie. I don't need ActionView. Remove the Railtie. I don't need
ActionMailer. Remove the Railtie. I don't need the asset pipline. You
turn it off in the config. (I think this should be a railtie. Since it's
not, it shows you tightly coupled it is). All that I'm left with is
ActionPack. It is so nice and slim. So concise. So focused. So
purposeful. I love it. For once, I can use Rails as a wrapper around
_my_ actual code. It's just an interface to the outside world. 

Rails no longer solves all my problems like it did when I started using
it. Now it just helps and I think that is good. I think many people look
to Rails as his god like thing that will just solve everything for you.
It is not that and it will never be. This is the way it should be.
Everything I no longer like or use can be removed from the framework.
You simply _could not_ do this before Rails 3. I think that's why I keep
coming back to Rails. Granted I know Rails like the back of my hand. I
can pretty much do whatever I want or could dream of inside the
framework. I don't mind jumping into the source to see what's up. In
general, it's a nice and comfortable place. On one hand I feel it's
bloated and doesn't focus on problems building modern internet based
applications, but I can bend it to my will and make it so. I can remove
all that I don't need, or have it all if I want a fullstack experience.
But as time goes by, I become increasinly disinterested because I no
longer need it like I once did. I don't need to solve all my problems. I
don't need scaffolding. I don't need all the things that initially
turned me on to it. I on longer think of it as _the tool_ but just
another one in my toolbox. And as more applications completely HTTP API
driven they will no longer need most of the stuff either enabling them
to revaluate their options. But until then, give me ActionPack or give
me death!
