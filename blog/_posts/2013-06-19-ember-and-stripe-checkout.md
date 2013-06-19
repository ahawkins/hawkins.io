---
title: "Ember & Stripe Checkout: Time to Get Paid"
layout: post
---

I don't think anyone has covered this topic before. [Stefan
Penner](http://twitter.com/stefanpenner) mentioned this topic in our
secret volcano base chat room. I figured I'd take a stab at it. It
came out as nice as I thought as it would. Unfortunately, the most
awkward part of any ember app is interacting with non ember code. I'm
looking at you every jQuery plugin ever. Stripe provides their
checkout.js script. It essentially turns a script tag into a button
that generates a stripe charge token which you can post to the server.

Integrating their checkout.js script is not so hard. I've put together
a fiddle for those interested in it. There is a `Product` model. It
describes the price, description, and currency. There is a view that
knows how to render a button. Pressing the button triggers an action
on the controller. The controller then uses Stripe's library to
generate the charge token. Once the charge token is generated,
promisified ajax is used to finally commit the charge.

I like this setup because it's widget friendly. You can render as many
buttons as you like for any number of products. So you could do
something like: `{{render purchase_button myBook}}` or `{{render
purchase_button myCar}}`. It also uses Stripe's nice UX for collecting
the CC info.

Here's the JSBin. Tomorrow I'll show you how to put a custom form
togehter.

_A word of warning._ This is not exactly how you should do this real
world. You would not keep the secret key on the client. Instead, post
to your server which knows the secret key and thusly makes the secure
request to stripe. This code is like this to demo the entire flow.
You've been warned!

<a class="jsbin-embed" href="http://jsbin.com/alesuk/6/embed?live">Ember + Stripe </a>
<script src="http://static.jsbin.com/js/embed.js"></script>
