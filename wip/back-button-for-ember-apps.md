---
layout: post
title: "Back Button for Ember Apps"
hide: yes
---

I recently had a requirment to create a back button for an app. The
back button would take the user back to the page they previously
visted. The app would also display a short list of the recently visted
pages. The list is more than just URLs, but also the context
associated with the page. This was a fun problem that was actually
pretty easy to implement.

My approach was to use the same arguments that are passed to
`transitionTo`. That way I could simply call `transisitionTo` or
`replaceWith` when the button was pressed. This also saves the context
passed to the route. So when the user goes to `/posts/1`, I have the
actual `App.Post` object and not just the ID. This approach allows me
to keep an array of objects. In theory I should be able to just
capture `arguments` in `transitionTo` save them, and reuse them later.

This implemenation worked out rather nicely. The route name and
context were captured when the user clicked links. The app's back
button worked as expected. There was one major issue: `transitionTo`
is not called when loading the application. Here's an example: If you
opened the app via `http://app.com/posts/1`, the initial state would
not be on the history stack. This means the user could click a link to
`/posts/2` and not be able to go back.

I needed to find a way around this. I looked through the routing code
and eventually found a code path that is executed under these
conditions:

1. The user clicks a `linkTo` link
2. The app changes state via `didTransition` in a route events
3. The user loads the app via a routable URL.

This code sits in the router. It's the `didTransition` method. It's
called with the context and all the route handlers. This means it's
called with route objects (if the route is nested:
`/posts/1/comments/new`). You can simply patch this method to store
the data in an array.

```coffeescript
Ember.Router.reopen
  history: []

  didTransition: ->
    handler = Array::slice.call(arguments).pop()

    entry = [handler.name, handler.context]
    @get('history').push entry

    @_super.apply this, arguments
```

The handler variable holds route object we're entering. The obtuse
code is getting the last element in the arguments array. This is the
leaf node in the routing tree. We can save the name (EX: `posts.new`)
and the context (EX: `App.Post`) into the history array and use them
later. We can simply create a `goBack` event in `ApplicationRoute` to
handle the button from anywhere in the app.

```coffeescript
App.ApplicationRoute
  events:
    back: ->
      history = @get('router.history')

      if history.length > 2
        history.pop()
        lastPage = history.pop()
      else if history.length == 2
        lastPage = history.shift()
        history.clear()
      else
        return

      if lastPage[1]
        @replaceWith lastPage[0], lastPage[1]
      else
        @replaceWith lastPage[0]
```

There are a few tricks in this code. The history array's last element
is always the current state. This is why `pop()` is called twice: once
to remove the current state, then to get the state they were on
before. This covers the case when the user has been navigating around
the site. The second `if` covers the case when the user enters app via
a URL, then navigates to a new state. In this case we just go back to
to start. The final `if` assures that the correct amount of arguments
is passed to `replaceWith`. Ember will throw an error if you pass an
agument (even if it's `undefined`) to a route with no context.
`replaceWith` is used to not push new items onto the history stack.
Now, all we need is a well placed `{{action "back"}}` or `@send
'back'` in an event handler if we're off to the races!
