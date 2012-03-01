---
layout: talk
title: Modular Service Layers for Rails Applications
---

### Abstract

This talks covers implementing a module service layer for Rails
applications. Each service is separated into it's own engine.
Example services: Email & SMS delivery, Email import, VOIP, among
others. The services designed to be accessed over HTTP, but since they
are engines they can be mounted inside your own application or as a
separate running application. The talk also covers TDD development and
creating a generator for more components.

### Notes

We faced a problem in a previous version of our product. We had many
tightly coupled dependencies to external services. This made it a pain
to switch services and hampered our development. We ended up splitting
all these components up into different engines and running them in a
completely separate app. The architecture of our service layer allows us
to mount the engines in our own application or separately like we
decided. The talk generally covers why we made this decision and how it
turned out. It is an overview of the entire process.
