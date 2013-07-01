---
title: "Ember & Twitter Bootstrap Tabs"
layout: post
segment: ember
---

Here's the next installment in my quick ember demo's posts. This one
shows how to integrate twitter bootstrap's tabs into an ember app.
Twitter's javascript is not used. I'm only using their CSS to make
them appear correctly.

There is a route that displays the tabs. There is an event to select a
new tab. Each tab link triggers the event. The router set's the
`activeTab` property on the controller, then it renders the correct
template into an outlet. The view has an observer on `activeTab`.
When `activeTab` changes, it applies the correct `active` class. This
keeps the UI correct. There is one small wrinkle! The view's
`didInsertElement` hook is used to set the initial tab. The
`activeTab` observer only changes the tab when the view is in the DOM.
The `activeTab` is set in the router before the view is rendered. 
The guard prevents things from blowing up.

<a class="jsbin-embed" href="http://jsbin.com/elenaz/1/embed?live">Ember + Bootstrap
Tabs</a><script src="http://static.jsbin.com/js/embed.js"></script>
