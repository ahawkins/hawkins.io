---
title: "Ember & Bootstrap Modals"
layout: post
---

Modals & Ember are a tricky thing. They are tricky for a few reasons.
1) there is an animation involved, 2) they may be inserted into the
DOM in a number of ways, 3) Each use case is different. The first question is: do
you need a route for it or not? How about an outlet? Or is it
contained inside another view? Is it part some large flow?
All these questions have their own answers which creates a unique
scenario. This means there is no standard way to do it right now.

Here is a technique I've used in my apps. I like to have a `modal`
outlet. You can `render` into the outlet using events. I like this
because I know I'll have a controller/model/view triple if needed.
This is more difficult with other strategies. The modal itself is a
standard ember view. A layout is used to ensure the view wrapped in
the correct HTML. The underlying modal template is only concerned with
putting stuff inside the modal. Animations happen using CSS by addd
the `in` class. This is standard twitter bootstrap. The `close` events
are delegated to the view. The view removes the `in` class starting an
animation and a `transitionend` event listener is added. When the
transition finished, the view delegates to the controllers `send`
method to pass a `close` event up the chain to the route. The route
uses a workout for "unrendering" (technical term: disconnect outlet).
The route renders an empty template into the `modal` outlet.

You can follow this
[thread](http://discuss.emberjs.com/t/modal-views-can-we-agree-on-a-best-practice/707)
for more info on modals.

<a class="jsbin-embed" href="http://jsbin.com/uzogun/1/embed?live">Ember + Bootstrap
Modals</a><script src="http://static.jsbin.com/js/embed.js"></script>
