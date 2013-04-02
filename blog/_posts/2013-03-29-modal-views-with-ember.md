---
layout: post
title: "Modal Views with Ember.js"
hide: yes
---

Modal views--ah modal views. There are so many possible
implemenations. There are so many use cases. One application I work on
probably could modal views implemented four different ways. Ultimately
how you implement a modal depends on the use case.

## Using Render

This is my prefered implemenation. Why? Because I consider displaying
a modal a different application state. Also, its easy to animate them
using css transitions. There is no need for jquery plugins or
anything else. When the view is in the DOM use CSS animations. When
the view is removed you can use CSS animations to remove it. This way
feels the most emberish to me because the modal exists in an outlet
and the outlet can be disconnected. These are the events we can do the
animations in. However, there is one **major** problem with this. You
need to override `destroy` to make it async. This should be a major
red flag, but I'm generally ok with it because the framework does not
(yet) provide a solid way to animate elements in and out. Anything
involving animation is going to be hacky so I've just accepted that
and moved on with my life. One side not about this approach: it's
easiest way if the modal need's a controller.

Here's an example use case. There a button to delete a record.
Pressting the button opens the modal where the user can confirm or
cancel. When they cancel the modal animates out. When they confirm, an
action is done, then the modal animates out. Here's how we can do
that:

```coffeescript
App.ModalView = Ember.View.extend
  classNames: ['modal']

  didInsertElement: ->
    @$().addClass('in')

  destroy: ->
    if @get('state') isnt 'inDOM' then @_super()

    @$().one $.support.transition.end, @_super.bind(this)

    @$().removeClass('in')
```

```handlebars
<button {{action confirmDeletion}}>Delete</button>
```

```coffeescript
App.ItemRoute = Ember.Route.extend
  events:
    confirmDeletion: ->
      @render 'confirmation_modal',
        into: 'application',
        outlet: 'modal'

    cancel:
      # NOTE: 'nothing' is an empty template.
      # Ember does not provide a way to clear 
      # an outlet yet.
      @render 'nothing',
        into: 'application',
        outlet: 'modal'

    delete: -> 
      # do stuff
```

Now your designer (which is probably you) can simply determine how
`.modal.in` should look. This is another reason I like this approach.
The designer does not have to know javascript (let alone Ember) to
determine how modal should look or be animated.
Also there are no bastardized jquery plugins. There is actually no fancy
javascript: it's straight ember with css animations. Verdict: this is
generally good, but relies on CSS3 animations and ember "hacks".
