---
layout: post
title: "What JavaScript Needs"
tags: [javascript]
---

JavaScript has gotten a big push in recent years. In the last 
two years there has been an explosion of JavaScript development. I
think Backbone was the catalyst for the revolution. Larger companies
(Google and Apple) have been using JavaScript to create full fledged
applications (Sproutcore) for a while. Recently complex client side are
starting to flourish. These type of applications have primarily developed by
engineers with legitimate software engineering experience and they need
tools. There is a large influx of traditional backend developers
(Java/Python/Ruby) with traditional and proven language experience
making the move to creating frontends to their platforms in JavaScript.
There is also a large amount of untapped potential: people who only know
JavaScript. I consider these people who are interested in creating
complex client side applications, but don't know how to architect them.
In short, there are ton of new web developers who don't have classic
engineering training. They don't have exposure to design patterns or
TDD. Some are still unfamiliar with MVC. I think this is a problem
waiting for a solution. I think part of the problem is that JavaScript
isn't a "real" language and still has some stigma associated with it.
I'd like to solve these problem somehow and lift the web up by elevating
JavaScript and empowering developers.

# Completely Separate JavaScript and the Browser

The tight coupling between js and browser causes many problems. This
makes it very difficult to develop and learn js without a
browser. The DOM is the reason why js is tied to the browser. This isn't
simply about being able to test js with a headless browser. This
is about separating the DOM side of js and core js. This basically
taking the good parts and removing the bad parts.

New developers must write HTML page to load in their browser to test
their code. WTF? This isn't good practice for serious development.
Imagine if you had to learn XML before you could run your Python code.
You can use Node to execute js outside the browser. I think this is
completely missing the point. Node is all about server-side js. What
about plain js? I don't want to have to open chrome, I don't want to have
to run `node inheritance_example.js`. I want to run: `javascript
inheritance_example.js`. This opens up a complete new word of
development!

JavaScript has a tough position: born for the browser, pushed towards outside
the browser, doesn't have enough functionality to do anything else. What
if we could to this:

```javascript
window = require('window');

window.elementById("#foo");

// in tests you could to this.
// no need for a browser, you only care about the DOM.
// all you care about is generating HTML. Rendering and displaying is a
// separate responsiblity.
window = require('window/mock');
```

I think this would be utterly fantastic. It would make every aspect of
js development much easier. This is also the first step to
making js a first class language. A standard library could be
built and more progress could be made.

# First Class Modules

I think everyone agrees that js needs support for `require`
(some concept of a load path). This implies support for discrete source
files with (hopefully) discrete functionality. Most other programming
languages have support this. Structuring HTML or using other tools
to compile js into one file is just annoying and wrong. There
are many solutions to these problems:
[require.js](http://requirejs.org/), [bpm](https://github.com/bpm/bpm/),
and [Modules in ECMA6](http://wiki.ecmascript.org/doku.php?id=harmony:modules).
Developers must come a solution for this to make js development.
*Disclaimer*: I don't think involving the browser is a good solution.
One possible solution is to simply treat to put "./" on the load path.
The js VM simply has to have read access to files in that directory.
It's common practice to package js applications as a single directory.
It's the browser's VM to make files available over HTTP. For example:
say you have this directory structure:

```
./
 - controllers.js
 - models.js
 - views.js
 - app.js
```

```javascript
// one version
controllers = require('controllers')

// EMCA6
import * from controllers;
```

`app.js` would work fine outside the browser and inside the browser.

# Standard Testing Framework

Testing is an extremely important part of software engineering. I think
you cannot have successful engineering without automated testing.
JavaScript needs to level up its testing infrastructure. There are many
competing test runners. There is a difference between testing tools like
Casper.js and test runners like qUnit or Jasmine. JavaScript needs to have unit
testing support built into the standard library somehow. This enables
engineers first class testing support. I think qUnit is a perfectly
viable candidate to be "the" testing framework. Inside qUnit you can use
other tools (like interacting with browsers) to complete your tests.

# Change The Culture

This is not a technical challenge but a community challenge. Technical
challenges can be evaluated with logical ruthlessness. Changing culture
is god damn difficult. It's the hardest thing to ever do. I think we can
do it though. We are sitting on the edge of a revolution in web
applications. JavaScript is our weapon in this war--for better or for
sure. JavaScript has won over the web and that's how things will
continue.

We need to do our best to encourage existing and new developers to
strive to become software engineers and not simply "JavaScript
developers." The days of: "I can program jQuery" are long gone (and
since when was jQuery a programming language?). JavaScript is no longer
the realm of copy and paste scripts from random web pages. There are
still people doing this. These are not the people I want to engage. I
want to engage passionate developers who care about the web and the
techonlogies that compose it. We need to focus on quality engineering
and push the language forward. We can't push the web forward unless we
push the tools forward. We need to encourage each other to try harder,
push harder, to architect, to learn, to test more, to not settle and to
reach higher. If you aren't ready to engage in this conversation then I
want to get you interested and developing.

JavaScript is becoming more prominent. There is more Node.js and js
conferences popping up. There are more meetups happening. If you attend
these events get to know your fellow developers. Encourage them and join
forces. Together we can promote a more engineering driven culture. I
think that will benefit all developers and tangentially all web users.

Shameless Plug: Here's what I think serious js developers should
be working
[toward](http://broadcastingadam.com/2012/07/ember_wish_list/).
