---
layout: talk
title: Creating a Sync Service
---

### Abstract

This talk covers the basics in creating a reusable sync service that connects an
application to various external accounts (Google, MS Exchange, others)
over a standard interface. It describes the processing for making the
service accessible over HTTP and bundling it inside a Rails application.
The talk covers the architecture using OOP design patterns,
requirements, and implementation.

### Notes

This talk covers a real life use case our company faced. We had a
tightly coupled exchange sync implementation. It needed to be extracted
into different parts so it could easily connect to MS Exchange, Google
and any other external resource we could think of. I've never seen this
discussed before so I thought it would be an interesting topic.
