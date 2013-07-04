---
layout: post
title: "Pagination with Ember"
segment: ember
---

Here is a much requested example: paginating an array! The code is
rather straight forward. There `page` and `perPage` calculate
`totalPages`. The `arrangedContent` property is sliced according the
`page` and `perPage`. The `page` property generates a simple array of
ember objects. Then loop over them using the item controller to set
the `disabled` property. The links set the `page` property and
the UI updates. The controller handles the action since it's the
easiest. You can adapt this to work with routes as well. The
`prevPage` and `nextPage` complete the common use case.

I'll show Ember Data next. This is easy to do with `findQuery`.

TIP: This is sorting friendly: simply set `sortProperties` and the UI
will update. Always use `arrangedContent` this plays nice with other
mixins.

<a class="jsbin-embed"
href="http://jsbin.com/ijoqom/6/embed?live">Ember + Simple Bootstrap
Typehead</a><script
src="http://static.jsbin.com/js/embed.js"></script>
