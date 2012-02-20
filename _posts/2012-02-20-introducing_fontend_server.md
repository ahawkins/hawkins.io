---
layout: post
title: "Introducing FronendServer"
tags: [rails]
---

Radium has turned out to be a real beast. After much delibration, we
decided to move to a pure JS frontend written in
[Ember](http://emberjs.com). He's written in JS and basic CSS. No
coffeescript or SASS. We needed an easy way to compile all the JS and
CSS files into two different files and host them on the web. We also
have a few other requirements.

1. Frontend code is completly separate of backend API.
2. Frontend code can be deployed and maintained independently.
3. Enable SASS/Coffeescript. I freaking love SASS.
4. Recompile assets in development
5. API proxy to avoid CORS issues in development
6. Easily deployable by non server guys.

So me being the server side guy had to sort this out. Josh turned me on
to: @wycats's [rake-pipeline-web-filters](https://github.com/wycats/rake-pipeline-web-filters).
It's an extension to rake-pipeline. Rake-pipeline is essentially the
Rails asset pipeline done in a less bitchy way. It's a rake extension
that does what rails pipeline does, except it's **much** more powerful.
You can easily define custom filters for things like minification.

Rake::Pipeline::WebFilters provides the heavy lifting. I wrote a simple
Rack app to server the stuff based on sensible defaults (convention over
configuration) and voilla! We have asset compilation and a development
server. Then combining some more glue code to connect a proxy and other
bits we have a more complete solution.

Introducting
[FrontendServer](https://github.com/adman65/frontend_server). Here's
what it does:

1. Compile JS/CS into Minispade modules
2. Compile LESS/SASS/CSS into css files
3. Reload assets in development
4. Proxy the backend API
5. Compile into one public directory
6. Deployable to heroku by any git user

I've used the classic Backbone todos app for an example. The example is
running [here](http://warm-ocean-3185.herokuapp.com/). 
Source [here](https://github.com/adman65/frontend_server_example).
