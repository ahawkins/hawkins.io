---
layout: post
title: 'Why I Love Volume 1: Sprockets'
tags: [ruby, javascript, gems]
---

[Sprockets](http://getsprockets.org/) is one of the most handy gems I've
ever used. It allows you separate javascript into multiple files and use 
`require` keywords. This was a god send for me. The application I'm
working has a TON of js. I was able to tame it with sprockets. I also
came up with a nice directory structure a long the way.

## The Problem

It all starts with application.js. You have one file. The documentation
says dump your javascript into this file--hell, put **all** your js into
this file. So you start writing a few ajax calls and various trickery.
20 lines. Then 50 lines. Then 100 lines. Then 500 lines. Then maybe a
couple thousand. Wait....a couple thousand? How did we get here? A
couple thousand for what? What page is this JS for? How do i *find* what
javascript I'm looking for? Hmmm. What about my jquery plugins? /public
is starting to get pretty packed. Now lets say you've got 25 different
pages. Each page needs their own JS to accomplish certain tasks. At this
point, is it smart to keep dumping things into the same file? I say no. 
It's time to get things whipped into shape. There's one thing I really
like about Rails: **convention over configuration.** The views folder is
setup pretty nicely. There is a folder that corresponds to the
controller that renders the view, and a file for the view name. It would
be nice to have this same structure for our javascript. When your JS
starts to become rather large, you'll have some common code that is
shared. This stuff belongs in an application.js file. So how can we keep
all this code organized? Sprockets.

## Hail the Conquering Hero

   Sprockets is a Ruby library that preprocesses and concatenates 
   JavaScript source files. It takes any number of source files and
   preprocesses them line-by-line in order to build a single 
   concatenation. Specially formatted lines act as directives to the
   Sprockets preprocessor, telling it to require the contents of 
   another file or library first or to provide a set of asset files 
   (such as images or stylesheets) to the document root. Sprockets
   attempts to fulfill required dependencies by searching a set of
   directories called the load path. 

Perfect. It can even combine all our js into one single file. We can
even minmize that later if we choose too. This means we can setup this
type of directory structure:

    /app
      /javascripts
        /pages
          dashboard.js
          settings.js
        /shared
          utility.js
        application.js

! That is pretty handy if you ask me. It becomes very odvious how the JS
is organized. It also makes it very easy to add
isolated bits of javascript for specific pages/widgets/etc. You can also add
other directories to the load path. This means you can create a /vendor
directory for your javascript. I love this because I can keep my
downloaded jquery plugins in /vendor with git submodules for easy
updating. So you could create this sort of structure for your
application:

    /app
      /javascripts
        /so_on_and_so_forth
    /vendor
      /javascripts
        jquery.js
        jquery-ui.js
        jquery.plugin1.js
        jquery.plugin2.js

Nice. You can also require other files as you would in ruby. For
example, say you're in application.js and you want to ensure that some
other javascript (like jquery) is loaded before this code is ran.

    //=require <jquery>

    // jquery dependent stuff here

Another example, say you're writing some JS for the dashboard and you
need to the utilities methods.

    //= require '../shared/utilities'

    MyApp.utilities.flashNotice('oh hai');

A require statement tells Sprockets to insert the content of the required
file before processing the rest of the document. I like this because it
makes it very explicit what JS is needed. It also prevents those wonderful
undefined method xxx for null errors. A require with `<file>` tells
sprockets to search the load path. A require without means it is a
relative path name.

## How I Integrated Sprockets

I took a similar approach to what I outlined earlier. I wanted a
javascript file for each separate page of the application and a some
shared folder where shared code lived. Then I wanted a way to easily
initialize the pages. Each page would live in it's own specific object,
so there would be no collisions. Here is the directory structure I came
up with:

    /app
      /javascripts
        /pages
          dashboard.js
          settings.js
        /components
          widget1.js
          widget2.js
        /shared
          utilities.js
        application.js
        jquery.js
    /vendor
      /sprockets
        /jquery
          /src
            jquery-1.4.4.js
            jquery-ui.js
            jquery.plugin1.js
            jquery.plugin2.js

My application has many shared widgets. I called them components because
they can be reused in any context in many different places. Sometimes
the JS for these things can be quite long, so I wanted a specific file
for each one so I knew where to look when something went wrong. The
default configuration for sprocket-rails has `/vendor/sprockets/*src`
on the load path. I didn't feel like changing it, and this way it lets
me group similar files. Sprockets will always process application.js
first. I use this to set the stage by requiring all different JS my
application needs.

```javascript
// application.js

//=require 'jquery'
```

jquery.js is a file simple loads all the stuff in /vendor:

```javascript
// jquery.js

//=require <jquery.1.4.4.>
//=require <jquery-ui>
//=require <jquery.plugin1>
//=require <jquery.plugin2>
```

Here's what one of the page file looks like:

```javascript
//= require '../components/widget1.js'
//= require '../components/widget2.js'

var DashboardPage = {
  init: function() {
      // do stuff, this is called when the page is loaded
  },
  // protip, use an ajax callback for the page automagically
  ajaxComplete: function() { }
};
```

I added a helper to initialize the page and attach the current page. It
generates javascript like along these lines and embeds it into the page:

```javascript
$(function(){
  #{page_name.titleize}Page.init();
  $('body').ajaxComplete(#{page_name.titleize}Page.ajaxComplete);
});
```

Then in the view (/app/views/dashboards/show):

    <% initialize_page 'dashboard' %>

## How it Worked Out

This was the best changed I've ever made to this application. Before the
JS was spread out into random files and it was a pain in the ass to
track down *how* it got included and *where* it was. Now this way I know
there is `/app/javascripts/pages/page_name.js` file and by the time that
code is executed, all the required code is added. It's also been very
easy to add new plugins. Drop the jquery plugin into /vendor and update
the jquery.js in /app/javascripts. Boom. Available everywhere. It is
also concatenated into one large file so instead of 20 or so (yes I know
this is bad) requests we now only have **1**. This made a big difference
in the load time. If you haven't used sprockets, I highly suggest you
check it out--especially if you have a js centric application.

**tl;dr**: Sprockets is a cool gem to organize and manage js your own
way. It also concatenates all js files into one single file. This makes
your page load faster. Use sprockets for inceased sanity.

