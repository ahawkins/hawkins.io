---
title: Testing Sites for Uptime in Parallel
layout: post
---

[Ben Mills](http://twitter.com/remear) tweeted me asking if I knew how
to test a list of sites for uptime. The catch was he wanted to do it
in parallel. It made sense to use a test framework. So here we are:
using minitest's built in parallel runner and metaprogramming to
generate an uptime test case.

<script src="https://gist.github.com/ahawkins/5817566.js"></script>
