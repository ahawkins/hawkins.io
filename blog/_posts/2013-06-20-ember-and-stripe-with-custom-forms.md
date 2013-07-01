---
title: "Ember & Stripe Custom Forms: Getting Paid Again"
layout: post
segment: ember
---

Here's the follow up my previous post on Stripe and Ember. Stripe's
checkout stuff nice and clean for simple buttons. What do you do when
you need your own form?

Implementing this is pretty much the same as using checkout. There is
a simple controller to manage the form. The form contains all the CC
information. The CC information is collected via bindings and passed
to stripe's library to generate a charge token. When the charge token
is generated we use a promisified ajax call to post the charge to
stripe's servers.

_A word of warning._ This is not exactly how you should do this real
world. You would not keep the secret key on the client. Instead, post
to your server which knows the secret key and thusly makes the secure
request to stripe. This code is like this to demo the entire flow.
You've been warned!

<a class="jsbin-embed" href="http://jsbin.com/umabin/4/embed?live">Ember + Stripe w/Custom Form</a>
<script src="http://static.jsbin.com/js/embed.js"></script>
