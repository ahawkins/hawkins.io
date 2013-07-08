---
layout: post
title: "Table Sorting with Ember"
segment: ember
---

Here is how to sort a table using Ember. I personally think this is
kind of awkward. Defining an array of column objects is awkward. You
could define a `isSortedXXXAsc` and `isSortedXXXXDesc` for each
column, but I think this is worse. It adds more logic into the
template and makes things more brittle. This example is slightly
brittle because you must reorder the columns property and the markup
to do display the table--but no logic changing is required. That being
said, here's how it works.

The `ColumnItemController` defines properties for `sortedAsc` and
`sortedDesc`. It uses the parent controller's `sortedColumn`, itself,
and `sortAscending` to calculate them. A different icon is displayed
for ascending and descending sorting. Clicking a column header that is
not sorted sorts that column in ascending mode. Clicking a header that
is sorted toggles the sort mode. Helpers are used format the dates and
currencies. This completes the common interaction found in most
applications.

<a class="jsbin-embed"
href="http://jsbin.com/omagiq/4/embed?live">Simple Sorting
w/Ember.js</a><script
src="http://static.jsbin.com/js/embed.js"></script>
