---
layout: talk
title: Implementing Billing
---

### Abstract

Take an abstract notion of accounting and billing and build a pure ruby
implementation. After the abstractions are complete, then use the simple
abstractions to build a system capable of charing credit cards, managing
usage based billing, subscriptions and customers. The code is developed
using TDD (with Rspec) and can be used in any piece of Ruby code or be
included in a larger service layer.

### Notes

This talk focus on solving a real world problem in our product. We
needed a component that could actually charge people, but it needed to
be free-form enough that it could adapt to store subscriptions, one time
of chargers, and support usage based billing. Credit card processing is
done with Stripe, but could easily be swapped out with another gateway.
