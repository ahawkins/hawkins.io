---
layout: post
title: "Ember Toggle Switch"
segment: ember
---

Here is a toggle switch for your Ember app. The CSS is not mine. It's
a slightly modified version of [Lea
Verou](http://lea.verou.me/2013/03/ios-6-switch-style-checkboxes-with-pure-css/).
The trick is in the Ember view. You cannot use only a checkbox. A
label is required. When the label is clicked, the checkbox toggles
which changes the css. The label must be connected to the checkbox
with the `for` attribute. All the checkboxes must have unique IDs.
This ensures you can have multiple toggle switches on one page and
everything works correctly.

There is one slight drawback with this example. The toggle switch is
wrapped in a div. If this is a problem for you, you can change the
`tagName` property on the `App.ToggleSwitch`. Then move the `for`
attribute into an `attributeBindings`. I've done it like this because
it's easier to see markup structure.

<a class="jsbin-embed"
href="http://jsbin.com/omagiq/1/embed?live">Ember + Simple Bootstrap
Typehead</a><script
src="http://static.jsbin.com/js/embed.js"></script>
