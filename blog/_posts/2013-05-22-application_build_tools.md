---
layout: post
title: "Javascript Application Build Tools"
tags: [ember, javascript]
segment: ember
---

Building Javascript applications is complicated. There are many tedious
tasks. There are many optimizations to must do as well. There are
organizational things to take care. Oh, there is testing too. There is
simply _alot_ to do. This post is all about comparing build tools to
help you decide which is right for your project.

## What's in a Build Tool?

A build tools range from simple to entirely complex. You could use a
`Makefile` (yes people do use those) or a simple rake task that
concatenates all source files. The tool may compile CoffeeScript
or SCSS. It may wrap your Javascript files in modules.
Build tools have many responsibilities. All the tools do roughly the
same thing: enable you to use CoffeeScript/SCSS/insert other compile
to JS or CSS language here, a choice of templating library
(Handlebars/Jade), and handle deployment scenarios in some way.
Most tools simply compile and concatenate all the
assets and then minify. This does not mean deploying to servers, but
deployment packaging.

## Popular Options

There are three popular choices. Language familiarity usually drives
the choice. If you know Javascript and have Node experience then go
for a Node build tool. If you (like myself) know and love Ruby, then
choose a Ruby build tool. Here are the tools covered in this issue.

* Yeoman (Node): arguably the most popular. It should be easy to
  dominate when you are Google backed project. Uses grunt.
* Brunch (Node): a simple tool focused on elegance and simplicity.
* Iridium (Ruby): rake-pipeline based. Highly configurable and
  designed for heavy duty use and complex applications.

All there will be compared in these areas

1. Compilable Language Support
2. Module Support
3. Templating
4. Testing
5. Development
6. Skeletons
7. Vendored Code
8. Package Management
9. Deployment Packaging
10. Linting

---

## Brunch

Brunch calls itself a "HTML5 Application Assember". It's opinionated
and is extendable via plugins. It‘s agnostic to frameworks, libraries,
programming, stylesheet & templating languages and backend technology.

### Compilable Language Support

Many languages are supported via plugins. There are plugins for all
the popular ones (CoffeeScript & SCSS of course). There are also
plugins for Less and LiveScript. You may have to configure these yourself.
Brunch may not support your choices out of the box. CoffeeScript and
Stylus are the defaults. Its easy to add plugins after a new
application is generated. More on this in the skeletons section.

### Module Support

Brunch supports a different module formats. CommonJS is the
default. You can change this to AMD, none, or write your own. Brunch
also registers a global `require` function.

### Templating

All the major templating libraries are supported via plugins. They
may also be precompiled. Templates are registered as modules. Require
them like normal modules when required.

### Testing

Brunch bundles support for
[Mocha](http://visionmedia.github.com/mocha/). Test can run in Node or in a browser.
More documentation on mocha [here](http://visionmedia.github.com/mocha/).

`brunch test runs headless tests with mocha and JSDom. I'm very
skeptical of JSDom. I'm concerned about the performance and about how
well it mimics a real DOM. The pure headless slant concerns me.
Headless testing is nice, but at the end of the day you eventually
have to run tests in the browsers themselves. I'd rather see build
tools embrace this then walk around it.

### Development

Brunch is fast. It's very fast. It's impressive fast. Brunch also
sends notifications to the Notification Center on OSX. This
means you'll see compile errors or other warnings the second you hit
save. I read about this but I didn't expect it to work. It worked out
of the box! I'm not sure how useful it is, but I'm sure others will
find it useful.

Development is built around file watching. The final site is compiled
everytime a file changes. Brunch does include a server, although
starting it weird. You can start a server with: `brunch watch
--server`. 

Brunch has a live reloading plugin. This will automatically refresh
the browser when code changes. This is handy for the "refresh,
alt-tab, reload" workflow.

### Skeletons

Brunch applications are created from a skeleton. The default skelton
configures these things: HTML5 Boilerplate, Chaplin (Backbone),
CoffeeScript, Handlebars, and Stylus. If you want a Backbone app this
is great. If you want something else you must know upfront. It's hard
to undo the configuration. Ember developers don't worry. There is a
skeleton for Ember apps. There is also a skeleton for building a
standalone Javascript library. I believe there is a barebones skeleton
if that is your thing.

### Vendored Code

Brunch includes a `vendor` directory. You can also configure a load
order for vendor code. This is extremely important. This means you can
configure jquery-ui to load after jquery. Vendored code is not wrapped
in modules. It's simply available. You don't have to require code in
`vendor/`.

### Package Management

Brunch does not handle package management. Simply download the source files
you need and drop them into `vendor/`. Package management support
via Bower is planned for the next major release.

### Deployment Packaging

Packaging the app for deployment happens via: `brunch build
--optimize`. The `--optimize` flag uses a minifier (if the plugin
is installed). Plugins can also tie into the optimize flag. There is a
plugin for optimizing images. `brunch build` compiles all the files
into `public/`. Now it's your responsibility to serve the files. The
readme describes how you can host the app on various systems. However,
Brunch does none of this for you. All of this your responsibility.

### Linting

Liniting is supported via plugins. There are plugins for JSLint and
JSHint.

---

## Yeoman

Yeoman is arguably the most popular build tool. It was introduced at
Google IO. Google is behind. Addy Osamni is involved with it as well
other other big names like Paul Irish. It's powered by Grunt and
Bower.

### Compilable Language Support

CoffeeScript and SASS are supported out of the box. Other languages
are supported by installing a plugin and then updating the `Gruntfile`.

### Module Support

Yeoman uses AMD. Yeoman goes through a setup wizard when generating a
new app. You can select ECMAScript 6 module support in the wizard.

### Templating

Yeoman does not support a templating language out of the box. This is
a glaring failure. I wanted to write Handlebars templates. There is a
plugin for that. However, annoying configuration is required--just
like most Grunt tasks. This also required customizing the server task
to run the handlebars task. The watch task also had to be updated.
All in all it was a very annoying and frustrating experience.

### Testing

Mocha and PhantomJS are used for testing. You may also open
`tests/index.html` in the browser. `yeoman test` opens
`tests/index.html` with PhantomJS and reports the results. Results are
also sent to growl if you like that sort of thing.

### Development

The development cycle happens very quickly. Run `yeoman server` and a
preview server starts. The server is very fast. No complaints here.

My complaint is with Grunt. Developers have to pay attention to their
application setup. Concatenation order must be specified. Compile
orders must be specified. There is a fair amount of configuration
that must be kept up to date. Development happens quickly after that's
worked out.

### Skeletons

Yeoman has supports few skeltons out of the box. The big three are
supported: Ember, Backbone, and Angular. You can generate a new ember
application with `yeoman init ember`. I recommend using a skeleton
instead of trying to setup all the plugins yourself.

### Vendored Code

There is a `vendor` folder inside the `scripts` folder for vendored
JavaScript. There is no dedicated vendor folder for CSS. This is a
mistake. You can add a vendor folder for CSS by updating the
Gruntfile.

### Package Management

Yeoman does have package management. Bower is tightly integrated into
Yeoman. Dependencies are specified in `component.json`. The format is
similar to `package.json` in NPM.  Yeoman also exposes serval commands
for package management. `yeoman install jquery` and `yeoman update`
are the most important. The files are placed into the correct places
so they can be required with require.js. You'll like Yeoman's package
management if you like Bower.

### Deployment Packaging

`yeoman build` compiles the application for deployment. It runs your
code through require.js's optimizer. It will also minify your code and
run images through an optimizer. Yeoman is not involved in the
deployment process, it simply makes assets ready for deployment.

### Linting

There no linting support baked in. There might a plugin.

---

## Iridium

**Disclaimer**: I wrote Iridium after finding nothing sufficient in either
Node or Ruby.

Iridium focuses on doing one thing extremely well: developing browser
applications. It makes optimizations to achieve that goal. Iridium
also includes many other things that don't fit directly into this
article. Here is a big one: different environments. People coming
from a Rails background take this for granted. Iridium configures three
environments: development, test, and production. You can configure
builds in each environment. Do you need to include some code only in
production? You can do that.

Iridium is arguably the most complex of all the tools. Its also the
most powerful. Iridium is built on two main things: rake-pipeline and
hydrogen. Hydrogen makes Iridium extendable with components (just like
engines/railties in rails). Rake-Pipeline is a library for defining a set of
input files and filters. Filters can be chained together to generate
the final output files.

### Compilable Language Support

Iridium generates CoffeeScript and SCSS (or SASS) by default. You
can also use Less by modifying the `Assetfile`. Vanilla CSS and
Javascript is supported as well.

### Module Support

Iridium implements a simple solution for module support. It does not
use CommonJS or any other more complex solution. It uses
[minispade](https://github.com/wycats/minispade) to wrap source files
in named functions. Simply `require` the name of the file where you
need it.

### Templating

Handlebars is the only supported templating language. This is an
opinionated choice. Only supporting handlebars enables complete
integration. Individual and inline templates are precompiled.

### Testing

Iridium has two pipelines: one for application code and
one for test code. All the test code is compiled down to `tests.js`.
You can open `test.html` in any browser. It is also framework
agnostic. PhantomJS is also supported. Running `iridium test`
opens `tests.html` in PhantomJS and reports results (all headless).
The PhantomJS runner works with QUnit and Jasmine.

### Development

Iridium is "refresh" friendly. Edit your source files and hit refresh
in your browser. There is a bundled development server as well. Run
`iridium server` to start developing.

### Skeletons

The initially generated project is framework agnostic. Skeletons
support common frameworks. Skeletons come in as generators from
engines. There is only one engine at this time: iridium-ember.
iridium-ember adds `iridium g ember:application`. You can write your
own skeleton by writing an engine and defining generators.

### Vendored Code

Vendored code is treated differently then application code. Vendored
code is not wrapped in modules. It is simply available. There are
three different types of vendor code: javascript, stylesheets, and
assets (images, HTML, fonts, etc). A Javascript load order may be
specified. All the vendored code is inserted above application code
in the final `application.js` and `application.css`.

### Package Management

Iridium does not support package management in anyway. If you want to
update jQuery/Ember/Handlebars/etc simply replace the file in
`vendor/javascripts`. It is possible to integrate something like Bower
via an engine.

### Deployment Packaging

Iridium supports multiple environments: development, test, and
production. Compiling in the production environment is deployment
preparation. Javascript and CSS minified and gzipped by default.
Individual and inline Handlebars templates are precompiled. A HTML5
cache manifest is also generated. All files are compiled into the
`site/` directory. You can simply put this directory on your
web server. Iridium also includes a production ready rack server.
Applications can be deployed to Heroku for free right out of the box.
The production server will also handle caching correctly so users only
download the code when it changes (via the cache manifest and HTTP
caching).

### Linting

`iridium lint` will run all Javascript through JSHint. This can also
be integrated into CI.

---

## My Recommendation

Sometimes it's easier to know what's not good instead of what is. I
think this way about Yeoman. Yeoman is built on top of Grunt. This is
a problem. Writing and maintain `Grunfiles` is a pain. Installing
plugins also requires configuration. Doing this for every plugin is
tedious. 

The package management is nice, but what does it really add? How often
are you managing dependencies? Is it really nicer than simply
downloading the individual files? Bower does not support all use
cases. Packages that have to built do not work. Ember-Data is a
perfect example. 

Overall it seems that Yeoman does not have great developer ergonomics.
It doesn't support a templating language out of the box. All in
all, Yeoman feels like a thin wrapper around grunt. I recommend you
look at other options before using Yeoman.

Brunch and Iridium are much better options. Brunch is very fast and
and opinonated. Brunch' default stack is optimized for Backbone. This
is easily solved by using a different generator. Ember developers will
have no problem with Brunch. Brunch does not use Grunt. This is a
wonderful choice. Brunch plugins configure themselves. Place your
plugins in `package.json` and go to work. There is minimal
configuration. Developing with Brunch was a pleasant experience.

Iridium is another excellent choice. Iridium uses some of Rail's best
ideas.  Convention of configuration is the biggest one. Developers
will do little or no configuration to get started. It's a full stack
solution. Iridium supports TDD, compilation, and deployment right of
the box.

In my mind there are only two choices: Brunch or Iridium. What you
use depends on what you like. Brunch is Node and Iridium is Ruby. If
you like Javascript and want a tool written in it then go with Brunch.
If you like Ruby then go with Iridium. Some good news for Ember
developers: you'll get along fine with Iridium or Brunch. Iridium is
more robust and has more features than Brunch. Brunch is small and
light and does one thing very well. Either way you'll be happy using
either one of these projects.

Here are links to get you started:

* [Iridium](https://github.com/radiumsoftware/iridium)
* [Iridium-Ember](https://github.com/radiumsoftware/iridium-ember)
* [Brunch](http://brunch.io/)
* [Brunch-Ember](https://github.com/icholy/ember-brunch)
* [Yeoman](http://yeoman.io/)
* [Mocha](http://visionmedia.github.com/mocha/)
* [Grunt](http://gruntjs.com/)
* [Rake-Pipeline](https://github.com/livingsocial/rake-pipeline)
* [Hydrogen](https://github.com/radiumsoftware/hydrogen)
* [Bower](http://twitter.github.com/bower/)
