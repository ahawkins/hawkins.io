---
title: "Fancy Ember Datepicker with Twitter Bootstrap"
layout: post
---

I showed how to make a simple datepicker in my previous post using a
computed property. The computed property parsed the text into a `Date`
object. This example is more userfriendly. It uses wonderful twitter
bootstrap
[datepicker](http://eternicode.github.io/bootstrap-datepicker). This
example fully integrates the library into our ember view.

The datepicker is create inside the `didInsertElement` callback. The
view connects to the datepicker's `dateChange` event to pass the
selected `Date` object back to the original computed property.

You may still type in dates matching the given format.

<a class="jsbin-embed"
href="http://jsbin.com/oqipey/2/embed?live">Ember + Bootstrap
Datepicker</a><script
src="http://static.jsbin.com/js/embed.js"></script>
