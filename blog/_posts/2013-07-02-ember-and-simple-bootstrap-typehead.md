---
layout: post
title: "Ember & Simple Bootstrap Typeheads"
segment: ember
---

Here's a dead simple twitter bootstrap's typehead example.
This example uses a simple array of strings. I started on an example
of using a list of Ember Objects (like binding to an
`ArrayController`) but then I remembered there is a bug in bootstrap's
typehead library prevents this. There is a workaround which I'll
put together later this week. In the meantime here is something to wet
your whistle. There is only one thing to pay attention to. The
`typeahead` function takes a `source` argument. It can be a function
or an array. Use a function since it reflects changes in the
source binding.

<a class="jsbin-embed"
href="http://jsbin.com/ocodom/3/embed?live">Ember + Simple Bootstrap
Typehead</a><script src="http://static.jsbin.com/js/embed.js"></script>
