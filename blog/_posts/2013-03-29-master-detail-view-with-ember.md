---
layout: post
title: "Master/Detail Views with Ember.js"
tags: [ember]
---

This is a common pattern we are all familar with. There is a list of
all the objects (the master view). Selecting an item from the master
view opens the individual item in a detailed view. Every application
has some form of this pattern. 

Implemeting this common UX pattern is challenging for Ember.js
newcomers. I think this is because most of them don't have experience
developing applications using desktop style MVC applications. Then you
throw HTML/CSS and routing into the mix it simply becomes too much to
handle. However, you should be able to follow along with this simple
tutorial and be able to implement it on your own. Form this point on,
I'll assume you have some general knowledge of how Ember.js
applications are structured and Handlebars.

## Getting Started

This demo app will have a list of DJ's. There is a sidebar that lists
all the DJ's. Selecting and item from the list opens up the detail
view. The detail view will contain their names and some of their work.
When nothing is selected, a prompt is displayed.

Ember apps are composed of states. States are represented as
`Ember.Route` objects. `Ember.Route` also map to urls. This
application will have the following states. I'll describe them with
URLs because it's easier to understand.

* `/` - The user opened the application
* `/djs` - The master list (nothing is selected)
* /djs/:name` - The detail view

It's important to note that all these routes are nested. We can
express the routes like this:

* Initial State
  * Master DJ List
    * Individual DJ View

The views will also be nested. So the main view contains the master
view, then the master view contains the individual view. This allows
us to keep the master list present when the user is on the detail
view. This makes it easy for them to switch between individual items.

Now we can start to code something.

## Describing the Routes

Let's start off by creating our routes. We'll have a DJ's resource
(the master list) and an individual route below that (the detail
view).

```javascript
App.Router.map(function() {
  this.resource('djs', function() {
    this.route('dj', { path: '/djs/:name' });
  });
});
```

That constructs the states described in "getting started." We don't
have to do anymore work on the routing. We do need to understand the
purpose of our individual route objects. 

Ember apps always have an `ApplicationRoute`. This route sets up
application state. It's primarily used to render the layout of your
application (nav bar, footer, etc). We'll also use it for that
purpose. 

The call to `resource` creates a few routes for this. We'll
use these to route objects: `DjsRoute` and `DjsIndexRoute`. `DjsRoute`
and `DjsIndexRoute` are slightly different. `DjsRoute` is the parent
state for everything below it. You could consider it this url: `/djs`.
`DjsIndexRoute` is this URL: `/djs/`. Note the trailing `/`.
`DjsIndexRoute` will be entered by default, however it will not be
entered if we go to `/djs/markus-schulz`, but `DjsRoute` will. We'll
use `DjsIndexRoute` to display the prompt to select a DJ.

`this.rource('dj')` inside the `djs` resource creates a nested setup.
The `DjsDjRoute` refers to `/djs/markus-schulz`. This is our
individual item view.

Ember.js will automatically generate these route objects for us. We
can defining them explicitly if we want. We don't need explicitly
define them in our code for this demo to work. This explains why you
will not see the route objects mentioned explicitly.

## Writing the Templates

Ember.js uses TDD (Template Driven Development). You describe the
application using Handlebars and it keeps everything in sync. This is
also important because it's the only thing Ember cannot generate for
you! It's possible to write an Ember application without ever writing
any Javascript (mind blown!). This demo has 4 templates:

1. `application`: the application layout (navbar)
2. `djs`: the list and a place to sick the individual items
3. `djs/index`: displays the prompt
4. `djs/dj`: The detail view.

I mentioned early that routes can be nested. Templates must declare
where the nested template can go. This is done with `{{outlet}}` in
handlebars. `{{outlet}}` means: stick the contents of my child states
in there. The application template will have an outlet, and the djs
template will also have an outlet. 

I'm going to write the templates using handlebars script tags. These
code snippets can be dumped into your `index.html` file as is. I've
also done this so you can see how the templates are named.

Let's get down to business.

```
<!-- application template -->
<script type="text/x-handlebars">
  <div class="navbar navbar-static-top">
    <div class="navbar-inner">
      {{#linkTo djs class="brand"}}On The Decks{{/linkTo}}
    </div>
  </div>

  <div class="container-fluid">
    <div class="row-fluid">
      {{outlet}}
    </div>
  </div>
</script>
```

```
<script type="text/x-handlebars" data-template-name="djs">
  <div class="span2">
    <ul class="nav nav-list">
      {{#each controller}}
        <li>{{#linkTo djs.dj this}}{{name}}{{/linkTo}}
      {{/each}}
    </ul>
  </div>
  <div class="span8">
    {{outlet}}
  </div>
</script>
```

```
<script type="text/x-handlebars" data-template-name="djs/dj">
  <h2>{{name}}</h2>

  <h3>Albums</h3>

  {{#if albums}}
    <ul class="thumbnails">
      {{#each albums}}
        <li>
          <div class="thumbnail">
            <img {{bindAttr src="cover" alt="name"}} />
          </div>
        </li>
      {{/each}}
  {{else}}
    <p>No Albums</p>
  {{/if}}
</script>
```

```
<script type="text/x-handlebars" data-template-name="djs/index">
  <p class="well">Please Select a DJ</p>
</script>
```

## Creating Route Objects

Creating the objects is quite easy. There's not much we need to write.

Let's start with the `ApplicationIndex` route. This is the same
concept as `DjsIndex` and `DjsRoute`. We use `IndexRoute` to redirect
to the `DjsRoute` when the user opens the app. When the user opens the
app it hits `ApplicationRoute`, which renders the main layout, then
`IndexRoute` which redirects. You can't redirect if you need to render
a templates. If we redirected in `ApplicationRoute` the app would have
no layout.

```javascript
App.IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('djs');
  }
});
```

Next is the `DjsRoute`. We'll customize the `model` hook to return
some stub data for the demo.

```javascript
App.DjsRoute = Ember.Route.extend({
  model: function() {
    return App.DJS;
  }
});
```

The `DjsDjRoute` is next. We need to create the route object to
customize the serialization. Ember will use the `id` attribute if
present. We don't have id's for this demo, so we'll just return the
name.

```javascript
App.DjsDjRoute = Ember.Route.extend({
  serialize: function(dj) {
    return {
      name: dj.name.dasherize()
    }
  }
});
```

## Tieing It Togther

We still need to actually create the `App`. We haven't created it,
just referenced it. I've done it backwards beacuse I wanted to focus
on the more important parts first. We also need to define an array in
`App.DJS`.

```javascript
var App = Ember.Application.create();

window.App = App;

App.DJS = [
  { 
    name: 'Armin van Buuren',
    albums: [
      { 
        name: 'A State of Trance 2006',
        cover: 'http://upload.wikimedia.org/wikipedia/en/thumb/8/87/ASOT_2006_cover.jpg/220px-ASOT_2006_cover.jpg'
      },
      { 
        name: '76',
        cover: 'http://upload.wikimedia.org/wikipedia/en/thumb/8/8a/Armin_van_Buuren-76.jpg/220px-Armin_van_Buuren-76.jpg'
      },
      { 
        name: 'Shivers',
        cover: 'http://upload.wikimedia.org/wikipedia/en/thumb/a/a1/ArminvanBuuren_Shivers.png/220px-ArminvanBuuren_Shivers.png'
      }
    ]
  },
  { 
    name: 'Markus Schulz',
    albums: [
      {
        name: 'Without You Near',
        cover: 'http://upload.wikimedia.org/wikipedia/en/9/92/Markus_Schulz_Without_You_Near_album_cover.jpg'
      },
      { 
        name: 'Progression',
        cover: 'http://upload.wikimedia.org/wikipedia/en/thumb/8/81/Markus-schulz-progression_cover.jpg/220px-Markus-schulz-progression_cover.jpg',
      },
      { 
        name: 'Do You Dream?',
        cover: 'http://upload.wikimedia.org/wikipedia/en/thumb/9/92/Doyoudream.jpg/220px-Doyoudream.jpg',
      }
    ]
  },
  { 
    name: 'Christopher Lawrence',
    albums: [
      {
        name: 'All or Nothing',
        cover: 'http://s.discogss.com/image/R-308090-1284903399.jpeg',
      },
      { 
        name: 'Un-Hooked: The Hook Sessions',
        cover: 'http://s.discogss.com/image/R-361463-1108759542.jpg'
      }
    ]
  },
  { 
    name: 'Above & Beyond',
    albums: [
      {
        name: 'Group Therapy',
        cover: 'http://s.discogss.com/image/R-2920505-1345851845-3738.jpeg'
      },
      { 
        name: 'Tri-State',
        cover: 'http://s.discogss.com/image/R-634211-1141297400.jpeg',
      },
      { 
        name: 'Tri-State Remixed',
        cover: 'http://s.discogss.com/image/R-1206917-1200735829.jpeg'
      }
    ]
  }
];
```

That's all. Now you can take the code snippets and create a simple
app. I haven't done that in this tutorial because that's very
dependent on your build tool if you're using one. However I will give
you some hints on how to put a simple one together.

Take all the code snippest and put them into a file named `app.js`.
Put the application code in, then the route snippets. Now create an
`index.html` files. Put the Handlebar snippets inside. Now downloads
ember, jquery, and handlebars. Write script tags for: jquery,
handlebars, ember, then finally `app.js`. Now open `index.html` in
your browser and you should be up and running. If you still can't
figure out how to get something running, please checkout the Ember.js
starter kit.
