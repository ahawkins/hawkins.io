---
layout: post
title: "Date Picker in Ember"
tags: [ember]
---

This post is a simple tutorial of how to create a basic date picker
for your Ember application. It does not use any library. It simply
transforms text into a date object. I'll post another tutorial on how
to integrate the jquery UI datepicker. That being said, let's get
started. 

It's very important to work with objects inside your application, and
not with Strings or more primitive representations. I work with dates
and times a lot for some reason. I usually need to compare dates, sort
them, or do some other stuff. This is usually a tedious process
because users can only input strings into forms. Ember is very helpful
here. Ember provides computed properties. You may have only seen
computed properties with one arguments. Computed properties can also
take a second argument: the value. The value can be manipulated before
setting another property. Then, through the magic of bindings, we can
access the property in other parts of the application.

We need a computed property that works like this: given a Date, it
will return the string represenation; given a string it will parse a
date. You can combine this with `Ember.TextField`'s value binding to
make everything work in concert.

Here's how it works when the user types something into the text box.

1. User types something into the box triggering a value update
2. `value` is bound to the computed property. The CP is called as a
   setter.
3. The CP parses the value and sets the date (if any)

Here's how it works when determing the initial value for the text box:

1. The text field's value property is called as a getter.
2. The CP lookups the date and returns it as a string (if any)

Here's the code for the date picker view:

Then simply use it like a normal view but with `dateBinding` instead
of `valueBinding`. This is very important! 

And a demo in JSBin:

<a class="jsbin-embed" href="http://jsbin.com/ehufox/2/embed?live">Date Picker Demo</a><script src="http://static.jsbin.com/js/embed.js"></script>

Here's everything in a gist:

<script src="https://gist.github.com/ahawkins/5729005.js"></script>

Happy hacking!
