---
layout: post
title: "Authentication With Ember Apps"
tags: [ember, javascript]
---

Here's a scenario. You're backend and frontend live in separate
places. They live on separate servers and separate repos. The frontend
is written in Ember. It communicates to the backend using an
authentication token. When the user opens your application on
"www.coolapp.com" for the first time they are shown a login form. Once
they are logged in they are redirected to the dashboard. If the user
opens the app via "www.coolapp.com/settings", the app checks if a user
is logged in. If the user is logged in `/settings` loads normal. If
the user is not logged in they are sent to the login form. Once they
authenticate, they are sent back to where they came from.

I've just described the most common pattern in web applications. It is
trivial to implement with Rails. It's next to impossible to implement
with Ember. There are few key details that make it so hard. Luckily
this [PR](https://github.com/tildeio/router.js/pull/19) by [Alex
Matchneer](https://twitter.com/machty) should solve all the issues
described in this post.

There are two major steps in the preparing a route in Ember. The first
is the model hook. This returns the data required for a particular
page. The model hook should be a promise. When the promise resolves,
`setupController` is called. `setupController` does whatever is
required to, well, setup the controllers. There is also a `redirect`
hook. The `redirect` is called after the model hook resolved. You can
use it bounce out of the route.

Here is one solution I tried. It does not work in all cases. I decided
to make the current user the model for `ApplicationRoute`.
`ApplicationRoute` is the first route your app enters so I figured it
was a good place to start. I thought returning the current user
promise from the `model` hook would be perfect. The child routes would
not load until the parent's model hook at resolved. If the promise was
rejected, I could take action to do something else. With that in mind
I wrote some simple code:

```javascript
App.ApplicationRoute = Ember.Route.extend({
  model: function() {
    return App.User.find('me');
  },

  setupController: function(controller, currentUser) {
    this.controllerFor('currentUser').set('model', currentUser')
  }
})
```

This honestly worked liked a charm! I was quite surprised. It worked
when loading "/". It totally broke the second I need to use it in
another route. Now, knowing that I had the `currentUser`, I could do
what I needed in other routes. 

```javascript
App.SomeSubRoute = Ember.Route.extend({
  setupController: function(controller) {
    controller.set('userFilter', this.controllerFor('currentUser').get('model')
  }
})
```

I opened up my application from the root. Then I clicked the link to
"SomeSubRoute". It worked. I made a change to the code for an
unrelated reason and refreshed the page. Now I had errors. There was
no current user anymore. Why is that? `SomeSubRoute` does not have a
model hook, so it is available synchronously. This means
`SomeSubRoute`'s `setupController` hook is called before
`ApplicationRoute` (which is async). So when it's called the current
user hasn't be loaded yet. Boo. You can't use the `redirect` hook
because it has the same problems.

The problem is even worse when trying to access a resource like
`/users/1/posts/5`. Assume you can only access that URL as an
authenticated user. You have model hooks that return `User.find(1)`
and `Post.find(5)`. Unfortunately the model hooks will fail to resolve
leaving your controllers with invalid or missing data. The `model`
hook is only called when entering a route via the URL so you must
clean up failures manually. This does not scale at all and is a
horrible solution.

There is a better solution. What if there was more control of how and
when we moved between states? Right now we don't have such control.
The PR mentioned above handles two core problems mentioned above: 

1. There are parts of the router that are async and sync. Mixing the
   two causes real problems.
2. No current way to halt a transition. Example, if the user is
   unauthenticated and tires to go `/root/sub`, the root route should
   be able to halt the transition through it.

The PR is to the low level router API. I cannot speculate what the
high level Ember API will look like. I do know this: everything will
be asynchronous and the developer will have fine-grained control over
the transitions it. This makes it possible to implement the common
authentication use cases we all know and love.

There is one work around in the mean time. The only way to avoid all
the problems in this post and in the PR. You avoid initializing the
application unless the user is logged in. This means all async and
synchronous transitions can rely on the current user being there. This
is actually quite easy to do. You can use an initializer and
`advanceReadiness` along with `deferReadiness`. Here's an example:

```javascript
Ember.Application.initializer({
  name: 'auth',
  after: 'store',
  initialize: function(container, application) {
    // don't boot until the user promise resolves.
    App.deferReadiness();

    // Assume 1 is the ID of the current user in a cookie
    App.User.find(1).then(function(user) {
      var currentUserController = container.lookup('controller:currentUser')
      currentUserController.set('model', user);

      // now you can access the current user in the routes with:
      // this.controllerFor('currentUser').get('model')

      // now boot the app
      App.advanceReadiness();
    }), function(error) { 
      console.error("Failed to authenticate!");
      Ember.Logger.error(error.stack);
      // this is where you abort your application
      // never calling advanceReadiness will prevent the app
      // from booting. You can do something hear to let
      // the user know they're screwed
    })
  }
});
```

You may also be interested in this [gist](https://gist.github.com/ivanvanderbyl/4560416)
showing how to set `currentUser` on all the controllers.

With all that being said:

> God I want to push this mother out so bad
> - Alex

Yes. Me too. This will really put the icing on the 1.0.0 cake. Also,
check this [gist](https://gist.github.com/machty/5647589) if you're
interested in the changes.
