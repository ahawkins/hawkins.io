---
layout: post
title: "Moving on from Rails: Part 2"
tags: [rails]
---

I was quite surprised by how much feedback I received on the original
[post](http://broadcastingadam.com/2011/11/moving_on_from_rails). You
should read the first one before reading this. I'm writing this post to
respond to some common questions, points, and concerns. 

## Setting The Record Straight

It seems the point of the previous post has been lost in the title. I
guess this my fault. I am not quitting or bashing Rails. I am "moving on
from Rails" because it is becoming increasingly less integral to how I
construct my applications. My applications are JSON based communicating
over HTTP. I still use Rails for all my web based projects with
different components added/removed based on the application's
requirements.

Rails is becoming less important because I no longer rely on it to be my
**application.** I try to use `ActionPack` as an interface to my code
which is **not** bound to Rails in anyway. In this setup, I do not the
traditional full stack setup. I don't use `ActiveRecord` and I don't use
`ActionView`. I continue to use Rails mainly because of `ActionPack`
since it's (from my experience) the easiest way to handle and respond to
HTTP requests. 

Oh, I use `ActiveModel` a ton because it's awesome as. I also use tons
of pits and pieces from `ActiveSupport` because `#present?`, `#blank?`
and `#underscore` etc are just too handy when you're doing programming
with strings.

## Alternatives

I was surprised (again) by how many blasted me about **not suggesting**
alternatives. I didn't know I supposed to. Still, I don't suggest any
alternatives because I don't think there are any for the way I structure
my applications. I could use Sinatra (and I do) in less complicated
scenarios. I like controller classes. I like `routes.rb`. With 30+
controllers and easily over 100 routes I think that would become an
unweildly application. Sinatra is probably closer to what I want, but I'd end up
building stuff from `ActionPack` into the application just to make it
work. Someone also suggested: [Renee](http://reneerb.com/) but I have
yet to play with it.

## Tunnel Vision

> This seems to be a recurring pattern with developers who have "discovered" 
> design and architecture through frameworks and can not seem 
> to separate that from the tools used.

I completely agree with that statement. I think this especially true of
_any_ full stack framework. If you are introduced to web development
through that stack and work with only that stack for a very long time,
it will be very hard to separate yourself from that train of thinking.
This has happened to me and only has significantly changed after building
much larger and more complicated web applications.

The other day I was speaking to someone who could not separate models
from database tables. There is no actual MVC going on there. Many people
think that models are just a wrapper around persistence. There is no
concept what does this model actually **do.** What does it represent in
your application? How does it interact with other models? Does it even
need to be persisted? Tunnel vision is not unique to Rails, but I think
it effects many new programmers who fall in love with the framework and
use it for years.

## PHP

I don't like PHP. I used to love PHP because it let me do all sorts of
cool stuff. I could create variable variables (I have no idea why that
exists.) plus all the other trickery you can do in the language. After
having programmed in a few more languages over the years, now I think
that PHP is fundamentally flawed as a language. Therefore, I have no
interest in using it or following it.

There are plenty of people who get paid good money write PHP. I'm sure
there are plenty of them who love PHP. I'm sure there are plenty of them
who love CakePHP or whatever framework they use (if they use it). Great
for them. As long as **you** are happy with whatever you do and whatever
tools you use then good for you.

## Replying to Dor

Dor wrote his own [post](http://www.tikalk.com/incubator/blog/defense-rails-replying-moving-rails)
in response to mine. Since he was nice enough to write a post which is
much longer than a tweet, I'll reply in long-form.

> So I think Adam is exaggerating and I think I can understand him 
> but it seems to me he is looking for an answer at the wrong place. 
> I am also not sure what is the alternative that he's suggesting...

I've found the answer to what I need. `ActionPack` is the answer.

> During the last 6 years there were so many posts of that kind... 
> but the music is still on.

The music is still on, but the tune has drastically changed. You don't
scaffold anymore. There was no MongoDB. There was no such things as
"JavaScript clients." New user expectations and technologies have
changed the a web framework's role. You can see this with 3.1 with
inclusion of the (much maligned) asset pipeline and seperation of
ActiveModel into an abstract concept reusable in other applications.

> I am nt sure why someone want to write such a negative post, 
> to me it seems like a waste of time. Why don't you write how 
> much you enjoy the new JackRobinson(tm) technology and its 
> remarkable advantages over Rails...

I don't consider it a negative post at all. I think it is an interesting
post which talks about the changing structure of web applications. 

> For example, the natural way in which CoffeeScript was made a 
> default on Rails 3.1 stack. In many languages you can pull the 
> first element of an array with the method []#first. Did you know 
> that in Rails you can also do [].second, [].third and so on until 40-something? 
> DHH, before he's a technology guy, he's a great product and 
> he thinks about the developers, that's what I like most about 
> Rails. Man, he's the g-- d--- Steve Jobs of development.

Coffescript is ok. It's cool that decided to make assets first class
citizens in Rails 3.1. However, I think the asset pipeline is not going
to be used when developer API based applications. Why do I need the
asset pipeline to serve assets if all care about is JSON? Hell, why would
I even worry about keeping assets in source control? It doesn't make
sense. These are two completely independent concepts. I use Rails to
serve JSON. Something else does whatever else. You can have a single
nginx box serving up static JS all day. I don't mess with that at all.
That's what makes Rails **great.** You can just that off. I turn it off
and pay no attention to it. I think the asset pipeline is generally a
useless feature for developing modern applications. 

> I agree today the web is much more about client-side but that's 
> what backbone.js and spine.js are doing, extending Rails.

These things have nothing to do with Rails at all. There is a complete
separation of concerns. They do not extend Rails at all. They
extend ANY HTTP based application. I could have an assembly program
serving up JSON it makes no difference. Backbone/Spine/Knockout/what have
you simply make it easier to create modern interactive UI's in the
browser.

> As for Ruby, the 1.9x version is fast and slick

Totally. 1.9.3 is a huge improvement over 1.8.7. I wish they would've
just skipped what 1.9.0,1,2 and went to right to 1.9.3 :D

One final note about writing Rails applications: most of the fun and
handy things you can do in code are done by ActiveSupport.

> All in all, I believe there is place for many flavours. 
> Just like in real life, mongrels are better than pure-breeds. 
> The environments learn from each other and so improve each other 
> and everyone are happier :)

Agree. Rails developers will learn to adapt framework to fit there needs
or they will simply move on.

## Summing It Up

> tl;dr - web development is changing, the frontend side of things is 
> gaining significance, while the backend is moving to, well, the background.
> No reason to be surprised there, right?

bphogan does a nice job cutting to the point as well:

> This is less about moving on from Rails and more about moving on from 
> building static pages from a database. Lots of web folks have been predicting this. 
> I've been saying for about two years now that the days of serving entire 
> HTML pages from the serverside are numbered. With things like Backbone, 
> I can bring up a Rails app without views and do something pretty awesome. 
> **And then it becomes a question as to what Rails offers.** (I bolded
> that for emphasis)
> 
> I love Rails. It got me back into web app development in 2005 after nearly 
> burning out. But Rails isn't exactly keeping up and people who need to 
> move on are going to do that.


Div does a better job of summing up my thoughts than I can do. Props
man:

> It seems like the title is a bit poorly chosen.
>
> The author talks about the importance of having a platform to cater 
> to the multitude of devices and other apps out there, and that this means 
> rails isn't the center of the universe anymore.
>
> To me, this does not necessarily mean moving on from rails.
>
> It does mean moving on from writing all code in rails.
>
> There could be a fullfledged backbone.js app powering a responsive ui, 
> and a distributed clojure jobqueue making sure messages are fanned 
> out to their destined networks in the backend. However, there is still room in this picture for Rails as a router of sorts.
>
> Rails still makes it easy to quickly build a solid REST api, and easy 
> to delegate long-running jobs to a separate system, in this type of architecture, 
> Rails would have roughly a third of the responsibility / code that it 
> has in a Rails only architecture, but it's still a vital component.

I hope that his post clarified the original. Now we can all move on with
our lives :D
