---
layout: post
title: "The Art & Science of Integration Testing Ember Applications"
tags: [ember, javascript]
segment: ember
---

This post is all about integration testing Ember applications.
Integration is also called "acceptance" testing. However you want to
call them, this post focuses on testing your application from
the user's perspective. This means filling in forms, clicking buttons,
or other interactions.

## Using JavaScript

You may want to keep your integration tests in JavaScripts for
numerous reasons. Having test code and application code share the
same language is a major benefit. You can interact with your
application code from test code. You cannot do this directly or
easily when using a test driver in another language. You may also want
to write tests in JavaScript because you hire JS developers, not X
languages developers.

Buyer beware: Using JavaScript for integration tests can be a painful
experience! The tooling is not as evolved as other languages. You will
have to write boilerplate code. However, you can get a test suite that
will execute in all browers. The reward is worth the effort!

### CasperJS

[CasperJS](http://casperjs.org/) is a toolkit built on top of
PhantomJS. It comes with an integration/acceptance library built in.
You can use its helpers to simulate clicking on elements, filling in
input boxes, and other things the user might do. It has a test runner
you can execute from the command line.

Using CasperJS creates complexity. CasperJS tests maintain
the application in a completely separate process (the page object in
phantom). You do not have direct access to the code running on that
page. This is problematic when you need to manipulate application
state. You have to constantly beware of what context your code is in.
Standard JS principles like closure variables do not apply. If you
want to pass a variable inside the test page to the remote page then
you must pass it in as an argument. This creates headaches on large
test suites.

CasperJS tests are only executable through CasperJS. This means,
indirectly, your tests will only run in Phantom. They will never
execute in a real browser. When you commit to CasperJS you ignore
cross browser testing. Think about this before committing to writing a
large test suite with CasperJS. You will defintely get going quickly,
but may pay for it in the future.


### Using the Browser Itself

The browser executes your application. You can use it run tests.
Running unit tests in the browser is a solved problem (see QUnit or
Jasmine). Writing integration tests is a bit tricky. The application
has to be running to test it. This creates complexity. There are two
options:

1. Run the application and tests in the same context.
2. Run the application and tests in different frames.

Running the application inside the same frame is difficult.sTo
ensures that tests not affect one another, the application must be
reset between each test.sResetting an Ember (or any JavaScript
application) can be difficult. This is typically unnecessary, because
if an application needs to be reset, the window can simply be
refreshed. It is possible to "reset" an Ember application by telling
the router go to the route state.sHowever, resetting Ember Data back
to a clean state does not yet work reliably.

At present, there are many problems with using this
method. It is not worth your time. You should use an iframe instead.

Running the application inside an iframe gives you control. You can
`reload` it between tests. This ensure a clean state between each
test. You can interact with the iframe DOM directly. This means you
have another `document` that you have to keep track off. You must
ensure that you execute code inside that document. Assume you have an
iframe with id "app". Get the window with: 
`document.getElementById("#app").contentWindow()`. You can use jQuery
to interact with the DOM just as usual.

This is where the boilerplate code comes in. You need to write helpers
to click on buttons and fill in forms. Remember that all of this has
to happen inside the frame. Helpers are important because they hide
this fact from the developer. Tests can be written quickly and easily
once you get all the helpers in place.

Now the rewards come. The tests run in the browser--any browser. Need
to test Firefox? Open the tests in Firefox. Need to test Internet
Explorer? Open the tests in Internet Explorer. Need to tests all browsers
at once? Try browser stack. This technique is truly powerful.

This technique is especially powerful when using
`DS.FixtureAdapter` since you control what data your application is
using. This gives you unique data for each tests.

There is one major drawback. A backend cannot be integrated.

If you want to test your backend API at the same time you will
probably need to use a different language for integration tests.

## Using Ruby

Using Ruby is a great choice for integration testing your application.
Ruby's testing libraries are much more advanced and robust than
anything you'll find for Javasscript. You may also want to use Ruby so
you can interact with your server (Ruby on Rails) for example. Here's
an example. Your application uses Ember-Data to talk to a Rails
backend. You need to reset the database between each test then add
data needed for that test. This integration tests the client and
server at the same time. You cannot do this with JavaScript if the
backend is in a different language.

Ruby's testing tools are superior to anything for JavaScript. There
are wonderful test frameworks. There are also a wonderful of libraries
for interacting with browsers. You will need to use both to
integration test your application. You'll need a test framework. This
is for writing the actual tests. Then you'll need a browser
interaction library to talk to a browser.

[MiniTest](https://github.com/seattlerb/minitest) is the best testing
framework for Ruby. It's built directly into the standard library so
nothing else is required. [Capybara](https://github.com/jnicklas/capybara)
is far and a way the best browser interaction library for Ruby. It is
an abstraction around the browser. It provides a simple DSL for
interacting with the page. Capybara uses multiple adapters to connect
to different browsers. [Selenium](http://seleniumhq.org/) is the
default. It runs the tests in a real browser. There are also adapters
for headless webkit
[capybara-webkit](https://github.com/thoughtbot/capybara-webkit).
This is much faster than selenium. There is also
[poltergeist](https://github.com/jonleighton/poltergeist) which is an
adapter for PhantomJS. I recommend MiniTest and Capybara
w/Poltergeist.

Using capybara also provides a hidden benefit. The application state
is completely reset between each request. Using Capybara with MiniTest
(or RSpec) will open a new webpage before each test. This will prevent
state leakage between tests. However, if you setup external state you
will have to reset it. This accomplished with an iframe by reloading
it between tests. This is defintely less painful than doing it in
JavaScript.

Interacting with the application code itself is a bit awkward.
Capybara provides an `evaluate` method. This executes JavaScript in
the remote page. It will also return a ruby object. This may not work
when returning complicated JS objects (read `Ember.Object`). Be
concerned if you find yourself doing this too much in your tests. You
shouldn't have to interact with the application code itself. Instead
do it only through the UI.

There are other drawbacks to using Ruby (or any other language). It's
hard to acheive full crossbrowser testing. You can switch adapters to
test in different browsers. This can be problematic because you (the
developer) don't have direct access to the browser (since you're using
an abstractoin layer). Let's not forget Internet Explore. It is a pain
to test on multiple version of internet explore. I don't know if
Capybara supports Internet Explore in any fashion. 

This point also needs to be reiterated: your application is now bound
to two languages: javascript (for development) and ruby (for testing).
This means you need to hire polygot developers. You can no longer
higher JavaScript developers. They need to be able to write both.
Hiring competent JavaScript Software Engineers (let alone ember devs)
is difficult enough. Adding the Ruby requirement cuts down the
selection even more.

## TL;DR

Integration testing JavaScript applications is complicated. Here are
some bullet points to help you decide which is right for your app.

### JavaScript

* Eliminate cognitive switch by having application and test code in
  the same language
* Testing libraries not as roboust as other languages (IE: Ruby)
* More boilerplate code to write
* Fully crossbrowser test suite possible
* Node use is possible (especially if your backend is written in Node)

### Ruby (and/or Other Languages)

* Very robust testing frameworks (MiniTest)
* Capybara is the best browser library out there
* Good Choice when developing a Rails and Ember app in tandem
* Creates context overheard when switching between application
  development and writing tests
* Impossible to share application and test code

Choosing an integration test strategy depends on your application
architecture. Choose wisely because it will be with you for along
time. It's arguably the most important part of your product (besides
the product itself)!

