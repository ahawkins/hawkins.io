---
layout: post
title: 'Sproutcore Login Tutorial'
tags: [sproutcore, tutorials]
---

Sproutcore is probably the coolest thing I've seen since I saw rails way
back early in 2006. I think Sproutcore is the future of complex web
application because it is an execellent way to create complicated (and
elegant) UI's using Javascript. It uses KVO (Key-Value-Observering) to
keep the UI in sync with the model. Yehdua Katz put it this way: "the
view always represents truth." I will not write about Sproutcore (SC
from now on) because there is plenty of information to read on what it
is and how it works. They have an awesome
[guides site](http://guides.sproutcore.com) to learn about it. However,
there is still a lot of confusion on how implement some simple stuff in
SC! I've been dabbling with SC for a few months now--and now I'm finally
ready to pass on some knowledge. I write SaaS applications, so the first
thing I ever consider is "the user has to login." So that was my first
hurdle with sproutcore. I had to solve this problem: "How can I create a
login form with sproutcore and authenticate against a database of
users?" Well in order to solve this problem we need to do a few things:

1. Create an SC application with a form for username/password 
2. Figure out how to submit that form
3. Create an HTTP API to determine if the form is valid
4. Return some information to SC
5. Store that the user is logged in and notifty the SC application that
   it is in a different state.

We'll start out by creating a basic interface. We'll have two pages.
When the user goes to our application they'll see the login form. If
they login correcly, we'll show them some different stuff.

We need some way to get the data form the form to pass it off for
processing. SC.ObjectController will do this for us. SC.ObjectController
is a proxy to some underling object. However, we never bind directly the
object, instead we bind to the controller. That way when some
information changes in the controller (and thusly the underlying object)
the various things bound to it will change. This is where KVO comes into
play.

We also need something to process the data in the form. The processing
code works along these lines:

1. Send a HTTP request to the server
2. Tell the UI to update according to the HTTP response

We'll use a state chart framework to transition the application from a
logged out state to the logged in state. State charts a very nice way to
model applications. I suggest you google them to learn more about them.
Our simple application will only have 2 states: logged in/out.

Once we have the sproutcore application working correclty with some mock
login info, we'll hook up a simple web service written with Sinatra.

## Creating Sproutcore application

Sproutcore comes with some generators (similar to Rails). It has a
generator to create a basic application. **I am using Sproutcore
1.5RC1 for this** so make sure you have the proper gem version
installed. You can install the gem and generate a new application like
this:

    $ # enter a fresh directory
    $ rvm use 1.9.2@sproutcore-login-tutorial # if you want to use rvm
    $ gem install sproutcore --pre
    $ sc-init login_tutorial

Now you can start the server and see a hello world page

    $ sc-server
    # head over to localhost:4020 and choose 'login_tutorial'

## Creating the Login Page

Take a peek at `apps/login_tutorial/main_page.js`. This file defines the
intial view in our application. It creates a page with a label on it.
Every SC.Page must have a SC.MainPane as the mainPane property. The
mainPane contains the objects that are part of the view and displayed on
the page. We'll use this code as an example to create a new page that
shows our login form. We'll reserve the main page for the logged in
state since it's feasible to say that 99% of time the user is logged in.

Create a file named: `apps/login_tutorial/resource/login_page.js`.

Here is the skeleton:

   LoginTutorial.loginPage = SC.Page.design({
      mainPane: SC.MainPane.design({
      })
  }); 

Inside the mainPane will create a form with 2 texboxes and a button to
submit the form. Here is the scaffold code you can use to create the
view:

    LoginTutorial.loginPage = SC.Page.design({
      mainPane: SC.MainPane.design({
        childViews: 'form'.w(),

        form: SC.View.design({
          layout: { width: 200, height: 160, centerX: 0, centerY: 0 },
          childViews: 'header userName password loginButton'.w(),

          header: SC.LabelView.design({
            layout: { width: 200, height: 24, top: 0, centerX: 0 },
            controlSize: SC.LARGE_CONTROL_SIZE,
            value: 'Login Required',
            textAlign: SC.ALIGN_CENTER
          }),

          userName: SC.TextFieldView.design({
            layout: { width: 150, height: 30, top: 30, centerX: 0},
            hint: 'Username'
          }),

          password: SC.TextFieldView.design({
            layout: {  width: 150, height: 30, top: 80, centerX: 0 },
            hint: 'Password',
            isPassword: YES
          }),

          loginButton: SC.ButtonView.design({
            layout: { width: 100, height: 30, top: 120, centerX: 0 },
            conrolSize: SC.HUGE_CONTROL_SIZE,
            title: 'Login'
          })
        })
      })
    });

We still have to connect the controller to the data and setup the state
chart. Let's do that next.

## Configuring the State Chart

Firs thing we have to update the `Buildfile` in the root directory to
require the state chart framework. Change the only line in the file to:

    config :all, :required => [:sproutcore, 'sproutcore/statechart']

Now create a file named: `apps/login_tutorial/core_states.js`. This file
define the state chart. It will have 2 states: loggedIn and loggedOut.
When we enter the logged out state, the login form will be displayed.
The form will be removed when we leave the state. The main page will be
displayed when we enter the logged in state. Here is the code:

    LoginTutorial.statechart = SC.Statechart.create({
      rootState: SC.State.design({
        initialSubstate: 'loggedOut',

        loggedOut: SC.State.design({
          enterState: function() {
            LoginTutorial.getPath('loginPage.mainPane').append();
          },

          exitState: function() {
            LoginTutorial.getPath('loginPage.mainPane').remove();
          }
        }),

        loggedIn: SC.State.design({
          enterState: function() {
            LoginTutorial.getPath('mainPage.mainPane').append();
          }
        })
      })
    });

The state chart is in charge of handling the flow of the application. It
needs to be started when the user goes to the page. Open up
`apps/login_tutorial/main.js` and replace the content of the `main`
function with:

    LoginTutorial.main = function main() {

      LoginTutorial.statechart.initStatechart();

    } ;

Now, reboot the server and head back to the application. You should see
a shiny login form.

## Binding with a Controller

Now we need to create a controller. A controller manages data for us.
We'll create a controller with two properties and bind them to values
in the login form. First generate a controller:

    $ sc-gen controller LoginTutorial.loginController

Now create two attributes for the controller like so:

    LoginTutorial.loginController = SC.ObjectController.create(
    /** @scope LoginTutorial.loginController.prototype */ {

      userName: null,
      password: null

    }) ;

Now we need to bind the controller to the inputs. We'll set the
`valueBinding` property on the text fields to the correct value on the
controller. Then whenever the user types something in the form, the
controller's attributes will update. We'll use the controller to get the
data to actually login soon. Here is the code to bind the text fields to
the controller:

    userName: SC.TextFieldView.design({
      layout: { width: 150, height: 30, top: 30, centerX: 0},
      hint: 'Username',
      valueBinding: 'LoginTutorial.loginController.userName'
    }),

    password: SC.TextFieldView.design({
      layout: {  width: 150, height: 30, top: 80, centerX: 0 },
      hint: 'Password',
      isPassword: YES,
      valueBinding: 'LoginTutorial.loginController.password'
    }),

Reload the page and now you can type stuff into the fields. Then you can
check controller properties in the console. So for example, if you type
'Adman65' into the user name field you could evalue this in the console:

    > LoginTutorial.loginController.userName
    "Adman65"

Conversely, you could also set the value of userName in the controller
and it would update the UI:

    LoginTutorial.loginController.set('userName', 'rpm')

## Making the Form Do Something

The next step is make the login button do something. Pressing the button
fires an event. We can configure the button to call a method on a
responder. A responder is an object that knows how to handle the action.
We can set the responder property on our view so all actions are
processed by the same object. Our statechart will do the processing.
Here is the strategy:

1. Tell the view that state chart will handle events fired from it
2. Tell the button to call a method on the responder
3. Add a method to handle the action
4. Use that action to check the credentials

Set the responder like this:

    LoginTutorial.loginPage = SC.Page.design({
      mainPane: SC.MainPane.design({
        defaultResponder: 'LoginTutorial.statechart',

        //...
      })
    })

Update the button view like this:

    loginButton: SC.ButtonView.design({
        layout: { width: 100, height: 30, top: 120, centerX: 0 },
        conrolSize: SC.HUGE_CONTROL_SIZE,
        title: 'Login',
        action: 'authenticate'
      })

Now add a method in the state chart to handle the action

    LoginTutorial.statechart = SC.Statechart.create({
      rootState: SC.State.design({
        initialSubstate: 'loggedOut',

        loggedOut: SC.State.design({
          enterState: function() {
            LoginTutorial.getPath('loginPage.mainPane').append();
          },

          exitState: function() {
            LoginTutorial.getPath('loginPage.mainPane').remove();
          },

          authenticate: function() {
            // we'll fill this in later
            // you can call alert('weeeeee') to test it's working if you 
            // don't trust me :D
          }
        }),

        loggedIn: SC.State.design({
          enterState: function() {
            LoginTutorial.getPath('mainPage.mainPane').append();
          }
        })
      })
    });

## Mock Authentication

At this point all we need to do is check the credentials in the
authenticate method we just added. For now we'll just check to see if
the user has filled in both things, then move to logged in state. If
either of the values is blank we'll show an errors. Once we the UI 
working correctly, we'll added a simple web service to check
against.

    authenticate: function() {
        var userName = LoginTutorial.getPath('loginController.userName');
        var password = LoginTutorial.getPath('loginController.password');

        if(!SC.empty(userName) && !SC.empty(password)) {
          this.gotoState('loggedIn');
        } else {
          SC.AlertPane.error("Login information incorrect!");
        }
      }

Now, if you fill in both fields and hit login then you should see the
original welcome message. Otherwise, you get an popup error message.


## Connecting to the Web

No we'll create a simple sintra site that accepts a post and does the
same basic checking. Here is `webservice.rb`:

    require 'rubygems'
    require 'sinatra' # make sure you install this gem
    require 'json' # make sure you install this gem

    post '/login' do
      data = JSON.parse request.body.read

      if data['user_name'] && data['password']
        200
      else
        412
      end
    end

Sproutcore sends parameters as JSON encoded strings. We need to decode
the JSON to get the parameters. Now you can run the file like this:

    $ ruby webservice.rb

Now we have to update the authenticate method to post data to the
server:

    loggedOut: SC.State.design({
      enterState: function() {
        LoginTutorial.getPath('loginPage.mainPane').append();
      },

      exitState: function() {
        LoginTutorial.getPath('loginPage.mainPane').remove();
      },

      authenticate: function() {
        var userName = LoginTutorial.getPath('loginController.userName');
        var password = LoginTutorial.getPath('loginController.password');

        SC.Request.postUrl('/login', {user_name: userName, password: password}).
          notify(this, 'didCompleteAuthentication').json().send();
      },

      didCompleteAuthentication: function(response){
        if(SC.ok(response)) {
           this.gotoState('loggedIn');
         } else {
           SC.AlertPane.error("Login information incorrect!");
         } 
      }
    }),


We user SC.Request to create a HTTP POST ajax call. The second argument
is the data to send. Calling .json() will set the request body to JSON
encoded data. notify() adds a callback to handle the response. Finally,
send() actually sends the request. The first argument to the callback is
always the response. We check to see if it's ok then go to logged in
state, else show an error message.

Finally, we have to update the build file to proxy '/login' to sinatra.
Add this line to your `Buildfile`:

    proxy '/login', :to => 'localhost:4567'

## Wrapping Up

I moved through this example pretty fast since it's very basic. It is
intended to give you a rough overview of how you can string together a
controller, view, state chart, an web service to authenticate users and
update the UI accordingly. Here is some further reading:

* [Source](http://github.com/Adman65/sproutcore-login-tutorial)
* [More detailed login tutorial](http://blog.nextfinity.net/loginlogout-example-app-pt-1/)
* [SC.Request](http://wiki.sproutcore.com/w/page/12412900/Foundation-Ajax%20Requests)
* [More about statecharts in SC](http://frozencanuck.wordpress.com/2010/11/15/ki-now-the-official-statechart-framework-for-sproutcore/)
* [Sproutcore Guides](http://guides.sproutcore.com)
* [More about Sinatra](http://www.sinatrarb.com/intro.html)

Feel free to hit my up twitter @Adman65 or as Adman65 on #sproutcore in
freenode.
