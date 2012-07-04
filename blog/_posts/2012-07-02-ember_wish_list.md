---
layout: post
title: "Ember Ecosystem Wishlist for Ambitious Web Applications"
tags: [ember, javascript]
---

My startup has been dabbling in Ember for the past 6 or 7 months. That
is an eon in web dev time. Ember has advanced massively since then.
However, there is still a ton of work to do. We are building an
enterprise application on Ember. Our needs are driven by that space. I think
that most if not all of our wishlist items should be part of the core
framework. Why? Because Ember is the framework for ambitious web
applications (hell it says that in their banner). These are ambitious
features. I think Ember can truly make it possible to build a new
echelon of web applications.

Here's the list of things we'd like to push forward in the ember
ecosystem (and are currently working on). Most of these are related to
ember-data.

## Low Hanging Fruit - Pagination Support in Ember Data

There is no standard way to do pagination with ember data. Pagination is
not a hard problem. Determining a standard response format is. Here's an
example. `App.store.findAll(App.User)` should actually load them all.
Not just the first page if the API is paginated. This is a global
problem and should be solved at the framework level.

## Low Hanging Fruit - Integrating Push to Keep Client Data in Sync

All complex applications allow data manipulation outside of user
interaction. I mean not all data changes are done by users sitting on
there devices. The server may be syncing something in the background
which brings in new data. How is the client going to know about it? Is it
periodically polling the server? That's crazy. It's easy to write
code that pushes all changes. It should be equally easy to push that
data into data store regardless of what push service you're using.
Ember-data stores should define a simple interface to accept messages
over push. Perhaps, the store itself is a web socket client which can
be connected to your push stream. There are many different ways to do
this. Everyone will solve this uncomplicated problem in the same way.
This is exactly why the framework should do it. Ideally, there should be
no problems if you switch from Websockets/Pusher/Faye/PubNub/Boxcar/etc. The
messages always arrive.

## Low Hanging Fruit - Local Storage Support in Ember Data

Loading screens blow. I downloaded the data. I shouldn't have to keep
going to the server to get it again. You are probably using HTTP
caching, but that still creates network requests. Getting good
performance means cutting down on network requests. It's not very
complicated to do in [Backbone](https://github.com/jeromegn/Backbone.localStorage/blob/master/backbone.localStorage.js).
Ember data should support local storage by default. For example, you
create your store and you can set `storedLocally: false` if you don't
want it stored. I think that adding local storage to support to the
framework and enabling it by default would be a **major** win. Our app
is dealing with a lot of data. Loading in data takes time and reduces
performance. We only want to download that data once.

## Ambitious Addition - Integrate Crossfilter to Fast Filtering

Ember-data is slow. Crossfilter is blindingly fast. Crossfilter is perfect
for doing aggregates and filters. For example: sum all these payments.
Slice this array by this time range. Crossfilter is fast for doing
aggregate operations (think SUM/MIN/MAX/AVERAGE) and for filtering
(WHERE attribute = x). It's light years ahead of ember-data. Have you
seen the [demo](http://square.github.com/crossfilter/)?! There is a few
megs of data to download so be patient. Once the data is on the client
you can see it's fast. Ember data can be this fast--it just needs to use
crossfilter. There is one problem: most of the time you need ember
objects and not basic objects. Ember data would have to use crossfilter
as a query engine then use it's results to return Ember.Objects. I've
talked to some people who've already done this. It's a hack and
unfortunately the only way to get acceptable performance.

## Ambitious Addition - Ember Performance

This is a very broad issue and is being addressed in many different
ways by the core team and other interested parties.
The TL;DR is that ember just needs to be faster. There are many
ways to do that. Some of these have been or are in the process of being
fixed. Here are some issue's we've observed so far.

* `#each` simply blows. This has improved significantly.
* Don't destroy views when switching. Nearly every application has one
  panel where the active view is switched in and out. If you're on page
  A and go to page B, keep page A around. Going back to page A shouldn't
  redraw the view. We've implemented this in our application.
* Rendering collections: only redraw items that have changed. **UPDATE**:
  The entire view is redrawn if the array is replaced. When content is
  added to the array, only the new parts are updated. Unfortunately,
  Ember-Data replaces the array causing complete redraws.
* Ember-Data: the entire thing needs a lot of work.
* Computed properties are great, but why do they generate new data each
  time?

## Ambitious Addition - Finish ActiveModel::Serializers

`ActiveModel::Serializers` is simply awesome. It's the best way to do
JSON serialization. IIRC, one of its original core purposes was to
provide a standard interface to connect Rails to Ember-Data. I'd say
that it's 99% complete. Here are the important missing pieces. 

1. Include pagination data for Arrays. Solves the pagination problem.
2. Polymorphic association support. Polymorphism needs to be addressed
   on the ember-data side as well.
3. Use memcache for caching JSON and hashes.
4. Don't serialize objects from associations that have already been
   included in the object map.

## Ambitious Addition - Testing

Let's have that baked in testing approach from Sproutcore back. Let's
even hook it up to something like Casper to shake it up. We need a
standard application layout/setup (ala Rails) to make testing work.

## Ambitious Addition - Handling Bad Connections and Crashes: Gateway to Offline Support

Network connections go down. Browsers crash. These things happen. We
have the tools to make applications failure resistant. Let's take
your basic todo list application. The user adds a todo and for some
reason the server is down. What happens? Do we just say "opps,
sorry. Please try again." I don't think so. The framework itself can handle
these cases. Here is a proposed solution. Use a messaging queue backed
by local storage to buffer requests to the backend API. Requests that
match a set of failure conditions (503, 504, or timeouts) are enqueued
again and will be tried again later. This is a step towards offline
support at the data layer. There has been some discussion about this.
There are few things in the way. A request/operation object needs 
to introduced. This object is persisted in the queue. The adapter takes
the request objects then does whatever logic is needed and sends them to
the server. These objects would need to be tied to records as well.
Since operations to individual records are being tracked, this means you
can cancel operations to specific records. There are also race
conditions. Hell, there are lot of complicated things to worry about,
but solving this problem is **massive**. Imagine if applications simply
got support for this by using Ember. Boom, your application has some
level of fault tolerance and it may even save you a few customers. I'd
say this is hardest problem to work on but the pay off is fantastic.

## That's a Lot and It's Important

This is list is more about broad accomplishments and pushing the web
forward through Ember. Our company is actively working towards these
goals. We understand that some of these are lofty goals.
We want to lift Ember to meet this goals. We are looking into
working with core team to make these happen. We are looking for people
who think at this level and want to push the web forward. If you care
about ember and this stuff then hit me up on twitter or my manager Sami
[@zaui](https://twitter.com/#!/zaui]). Open PR's on ember and ember data,
that's important too.
