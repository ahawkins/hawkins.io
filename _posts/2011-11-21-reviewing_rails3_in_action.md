---
layout: post
title: Reviewing Rails 3 in Action
tags: [rails, books]
---

[Ryan Bigg](http://ryanbigg.com/) is writing a book called [Rails 3 In
Action](http://manning.com/katz/). I've been lucky enough to help read
the book and generally review its contents while it's been written. I
consider myself an advanced Rails developer, so when I read books like
this I look for them to cover specific things that new developers need
to know and how well the example integrate best practices. In this post,
I review [Rails 3 in Action](http://www.manning.com/katz/).


## About the Book

Rails 3 in Action is written to give people interested in learning Rails
an indepth look into creating a basic Rails application using TDD. The
book is divided into three sections and one appendix. Here is the table
of contents:

### Part 1: Getting Rolling

1. Ruby on Rails, the Framework
2. Testing Saves Your Bacon
3. Developing a Real Application
4. Oh CRUD!
5. Nested Resources
6. Authentication and Basic Authorization
7. More Authorization

### Part 2: Putting on the Bling

1. File Uploads
2. Tracking State
3. Tagging
4. Sending Email
5. Designing an API
6. Deployment

### Part 3: Further Enhancements

1. Alternative Authentication
2. Performance Enhancing Basics
5. Engines
6. Rack Applications

I was really looking forward to this book because the authors planned on
covering more advanced topics. That way, the new readers can go from
zero knowledge to going through an overview on advanced topics. The
beginning chapters are well written and cover all the basics. The
advanced chapters are very imformative. The engines chapter is most
likely the best documentation to how to write an engine except existing
code. One reason I really like this book is because current and popular
gems are covered throughout the book. Devise, Paperclip, Cucumber, and
RSpec are used throughout the book. I think this gives the book a very
current feel and reflects what developers are doing at this point.

## Part 1: Getting Rolling

I can honestly say that the first four chapters of this book are the
best at showing how to wire up a Rails application. New developers are
often confused by all the various moving wheels. They have questions
like: how can I call code from a URL? What is a route anyways? What goes
in a controller? How do I make a new model? How do I make a form? These
are all very basic questions that must be answered before anyone can
start making real applications. Bigg answers all these questions and
more. He starts by giving an overview of the Rails framework and
covers these Rails principles:

1. Convention over Configuration
2. REST
3. MVC.

It's very important to cover these ideas upfront so readers are well
aware of recurring themes in the book. The author demonstrates how to
create a very basic application. This is where the stage is set for
creating the example application. All important steps and pieces are
introduce before moving on to the next step. Ryan covers all these basic
parts:

1. Installing
2. Using a generator to create an application
3. Starting
4. Scaffolding
6. Migration
6. Views
8. Validations
9. Routing

These small portions are very effective because it demonstrates how to
do common tasks. All new developers should know how to do these things
before continuing onto the next step. This brings me to why this is **my
favorite Rails book I've ever read.** The book uses pure TDD to
develop the demo applications. 

The next chapter is "Testing Saves Your Bacon." The author goes through
a small example of using RSpec for unit testing. He describes BDD. BDD
stands for "Behavior Driven Development." It is essentially the same
thing as TDD, except tests respresent documentation and are readable by
stake holders. You can express this in code:

    class TestDriveDevelopment

      def strategy
        write_a_test(requirements)
        while(test_failing)
          write_implementation(test)
          run_test_suite
        end
      end
    end

    class BehaviorDrivenDevelopment < TestDrivenDevelopment
    end

The testing saves your bacon chapter is very short and suite. It's only
real purpose it to introduce Cucumber and RSpec. (More information on
BDD [here](http://pragprog.com/titles/achbd/the-rspec-book)) Now that
the reader knows the basics of using these test frameworks, they can
move through an excerise in creating the scaffold for a real
application.

Before, the reader only used a generated application to move through the
basic motions. Now it's time to set the stage for creating the
application used throughout the book. I like this chapter because it
covers things that are usually overlooked. The author mentions the book
will use Git. I find it funny that this fact is given very little
attention and is more annecdotal than anything else. Granted this is not
a book on version control, but I think that spending more time on why
developers should use version control would be beneficial--especially
because some readers may have no version control experience.

The sample application is a ticket tracking app. It is a _very_ slimmed
down version of [Lighthouse](http://lighthouseapp.com/). Ryan describes
the application in high level terms that can be translated to automated
acceptance tests. The rest of this section contists of writing cucumber
features and then their implentation. This process is informative for
new users.

There is one downside to these early sections. A large number of new
tools are introduced. This may be confusing for brand new Rails
developers. I've run into this problem before when I teach Rails. I use
the same technique: Teach Rails using TDD with Cucumber and RSpec. I've
noticed that new developers think all these tools **are Rails.** This is
not the case. The case is also complicated by the fact that Cucumber
uses Capybara to drive a browser. The line between all the different
tools blurs for new developers. This is not a problem with this book,
but a problem with any type of learning that overloads people with new
things at the beginning. I don't think there is anyway to get around
this. It is very important to introduce all these concepts and tools in
the beginning. The book can spend more time clearly defining each role
the tools plays. I've found that the link between Cucumber and Capybara
difficult. The readers will have a good understanding all the tools by
the time they finish the book, but I think it's wise to put more time
up front explaining each tool and why Rails developers use them.

Now, that I have off my chest, I can cover the best examples for
learning how to do basic CRUD I've ever seen. Chapters 4 & 5 are
magnificent peices of work. I wish I could give some my students these
chapters because they cover creating/viewing/editing/deleting in TDD
fashion so well. I think these chapters work so well for a few reason.
Readers may have a basic idea through previous experience, but they
generally are familar with creating a new record in a computer system.
New Rails programmers do not know how to make this process work. They
know what they want to do, but now how to do it. Since the author uses
TDD, he writes the test case first. The test suite is run. This shows
that system does not currently support that use case. At this point, the
reader has a very clear idea of what they are adding to the system. Then
the implementation is written to make the test case pass. **This
demonstrates precisly what code is required to do each use case.** This
is process is very helpful because the reader will know **exactly** what
the did to complete the use case. It also demonstrates the power of
having a test suite that covers the application so futher development
does not break existing functionality. After finishing the reader
finishes this chapter they will have good understanding of these
concepts:

1. Implementing RESTful routes
2. Using routing helpers to link to different pages
3. How to render new views
4. How to use partials
5. How to connect routes to controllers
6. And Most Importantly: How to do it all test first.

These are the fundamental skills all Rails developers should have. I
guartenee that after reading this chapter you will know how to do CRUD.

The next chapter "Nested Resources" covers associations and building
tickets for associated projects. This is essentially the same as the
previous chapter, except for creating models that must be associated
with other models. The Ticketee application has a `Project` model. A
`Project` has many `Tickets`. This chapter covers nested routes and the
basic of handling models with associations. It covers all the CRUD
options as well.

After the "Nested Resources" chapter all foundation is there for
creating a more complicated functionality. Every application allows
users to log in. Once you can determine that someone is logged in, then
it makes sense to allows specific users to do specific things. This
describes authentications vs authorization. Part 1's final two chapters
cover this topic in depth. And, god damn. These chapters are long.

The book uses [Devise](https://github.com/plataformatec/devise) to
handle user registration/sign in/sign out/confirmation. It is currently
the go-to solution for authenticating users inside Rails application. It
is a Rails 3 engine. This fact is important because it it referenced
later in the "Engines" chapter. The chapter follow the same flow as the
others: Write a test for a new feature. Implement the code to make it
pass. Chapter 6 covers creating users and allowing them to login. Basic
access control is added. Namespaced controllers are introducted in this
chapter. This is a helpful concept because it helps keep controllers
organized. Once the groundwork is set, Admin users are created and a
basic permissions system it implemented. This chapter is very
informative. I felt it was much longer than it needed to be. Chapter 6
seems to drag on forever, where all the previous chapters are snappy and
too the point. Once I got to part about creating Admin users, I had to
skip ahead to see how much is left. I think the second half of this
chapter could be split into it's own section. The author fits a ton of
information into this chapter. It may be too much for some readers.

Chapter 7 is the final chapter in part 1. It covers creating a more
complicated persmission system using [CanCan](https://github.com/ryanb/cancan).
This chapter is well written and thankfully shorter than the previous
one. The information it presents is precise and useful.

Part 1 is really quite good. I can say that first few chapters are some
the best I've read on on these topics. At this point the reader has
transitioned to Rails newb to somewhere just before the intermediate
level. Granted, they cannot be consider true developers until they have
experience under their belt, but Part 1 covers all the skills people
should have before moving onto the advanced stuff. This is where the
book takes a different approach. In the beginning of the book, you did
everything yourself. You wrote all the code and wrote all the tests. The
last two chapters of part 1 and sections of part 2 focus on leveraging other
people's code through gems.

## Part 2: Putting on the Bling

The first chapter in Part 2 covers uploading files with 
[Paperclip](https://github.com/thoughtbot/paperclip). 
I like this chapter because it covers adding a feature that is important
to serious applications. I also like that the author choose to use
popular gems because it reflects current practices. The chapter does a
nice job of showing how to implement file uploading _and_ retreiving
correctly. There is one thing I do not like about this chapter. It uses
paperclip. Carrierwave would've been a much better choice, but at the
time the book was written, paperclip was the best choice. We all know
things change fast in the tech world. It's very hard when writing a
book. Writing a book takes forever by today's standards. Rails 3.1 was
in development while this book was being written. Hard to stay current
sometimes.

The next two chapters add two features: state tracking and tagging.
There is nothing too fancy about these chapters. The book covers writing
a state tracking feature from scratch. I was suprised to see this, but I
think it's good for the new developers to learn how to do this sort of
thing. Tagging is very common too. It's not hard to implement, but it's
generally a solved problem so there are plenty of gems. The book covers
how to write your own tagging system. It does use the author's
[searcher](http://rubydoc.info/gems/searcher/0.0.6/frames) gem to
implement simple searching. My guess is the gem was written specifically
for the book. I think it was a good choice to write the tagging system
by hand and use a gem to create simple search functionality. This
doesn't distract from the main point: creating functionality to manage
tags.

Chapter 11 is all about email. It provides a well thoughout overview to
implementating email functionality inside Ticketee. The reader will
learn how to setup an observer (in `app/observers` where they [should
be](http://broadcastingadam.com/2010/10/app_observers)). I'll admit I
got a bit happy when I saw the author add chosen not to put them in
`app/models`. I mean, why would you? They're not models? They're not
presisted, they are completely separate! I digress. I only have one
negative comment to say about this chapter: The book specifically
assumes you have a Gmail account. The author also uses the Gmail gem to
fetch email from a gmail account. I think it would be better to use the
built in Mail retreiver methods instead. This keeps the toolbox small
and my be less confusing to new developers. The test cases also involve
the network in tests. This should come with a big warning saying: HERE
BE DRAGONS! It's not good to introduce the network into the test suite
because it can create random failtures unrelated to the code. What
happens if the connection goes down? Test fails. Is it the code or the
network? This should be mentioned.

When I first started to talk to Ryan about his book he mentioned that he
was writing chapters on creating API's and deployment. I got really
excited when I heard this. Why? Simply because you don't see these
topics covered in many Rails books. You could write an entire book on
only deploying Rails applications--and they have. You could also write
an entire text on creating well crafted HTTP API's. Luckily for readers,
the author has compressed these very large topics down into manageable
portions that you can learn from! 

I think the API chapter is damn good. It's simple and straight forward.
I think it demonstrates how **easy it is to write RESTful API's.** This
is where Rails really shines through. It's so easy to return objects in
XML or JSON. The author users JSON of course, then easily shows you can
serve back XML if you are crazy enough. He also covers how to rate limit
it. The RSpec tests read very nicely. The chapter also shows how to
create versioned API's by using namespace. This chapter is very well
put together overall and shows Rail's real strenghts. The author left
one thing out: The params parser. It would've been nice to create an
example application showing how to use the API. The params parser allows
developers to POST/GET/PUT/DELETE with JSON/XML as the body of the
request. The params parser will parse the text and return the proper
data structure. This is an execellent way to pass complicated
parameters. This may be outside the scope of the book, but it covers so
many cool things I felt this one was left out.

The deployment chapter is awesome! I think these chapters really make
this book stand out because it gives a **complete** overview being a
Rails developer. Here's the general process the author goes through:

1. Setup a VM
2. Install RVM
3. Install Ruby
3. Create a deploy user
4. Setup authentication w/SSH
5. Install a database
6. Using github for deployment (setting deploy keys)
7. Using capistrano
8. Configuring a web server
9. Configuring passenger to serve the Rails application.

There's not really too much to say about this chapter even though it's
well done. It provides a blueprint for setting up a very basic
application server. It is by **no means** a guide on how to setup a true
production grade box. It does show you take a barebones system and throw
a Rails app on there. Every rails developer should know how to do this.
I consider this a mandatory skill when I think about hiring
people--which is why I'm so glad the book covers it. After reading this
chapter you'll know how to do this: Setup Ubuntu with RVM, PostgreSQL,
Nginx, and Passenger. This chapter is a good reference for anyone who's
never done it before.

That's the end of Part 2. Part 3 holds much promise. Personally, I would
buy this book for part 3 since that has stuff I'm interested in. The
first two sections do not really apply to me. This is where we get into
the advanced stuff--and I like it.

## Part 3: Leveling Up

If you already know Rails and want to learn more then this section is
for you. It covers some cool stuff that's covered in Rails books. This
book is book about developing Rails applications and not an exhaustive
reference of the framework. Now we get to see how we can start to make
our application do much more cool things.

The first chapter in part 3 describes how to setup external
authentication using Devise + OmniAuth (which is seriously awesome).
This is a very short chapter because it doesn't need to be any longer!
That's how easy it is to implement third party authentication. After
this chapter you'll know how to integrate GitHub and Twitter
authentication. Not bad for a short chapter.

The next chapter is on "Basic Performance Enhancements". I think this is
the weakest chapter in the entire book. I have a lot of experience
working with caching and there are technique that I hoped the author
would present, but did not. The title is "Basic Performance
Enhancements". The techniques in this chapter _are basic_ and do not
represent performance minded approach. The chapter focuses around the
three out of the four Rails caching strategies: Page, Action, and
Fragment Caching. The fourth involves Rails.cache which is essentially
manual cache operation, but very powerful since you can store anything
you like. Ticketee is a very basic application. It needs to be for the
purposes of the book. Since it's simple, you can use very simple caching
techniques. Expiring with sweepers is very easy to do in a simple
application. However, it does not account for associated events. For
example, say you have a comments controller and tickets controller. If a
comment is for a ticket, you'd have to sweep the ticket from the
comments controller. This is not the case in the book, but is the case
with using action caching and cache sweepers. I would've liked to see
more discussion on these matters. 

Fragment caching is discussed breifely, but not in major detail. It does
not into detail on creating different keys for different fragment, but
relies on Rails to do the dirty work. This hides some power from the
reader. Page caching is mentioned, but rarely application to any
legitmate web application. You can read my take on [Advanced Caching in
Rails](http://broadcastingadam.com/2011/05/advanced_caching_in_rails) if
you want to see what I think is important. This information is outside
the scope of the book. I've included the link as example of how
complicated it can become and to show why things were left out of the
book.

The author descides not to use memcached. I think this is a very bad
decision. He uses default which provides functionality not available to
memcached. The vast majority of people use memcached in production. If
they follow the code provided in this chapter it will not work in
production systems with memcached. The author uses cache expiration
based on a regular expression. This makes it easy to address problems
that arise from using cache sweepers. However, it is only applicable to
cache stores that can iterate over all keys. Memcached cannot do this.
I think this is the chapters biggest flaw because it uses techniques
that are not suitable to production applications. 

There is good news. It seems the author is working on addressing these
problems. I think he is adding a section on memcached and how to use
Rails.cache. I was suprised to see that he did not cover using the cache
manually. All the examples are focused around caching HTML or preventing
web request from hitting the server. He does not cover using Rails.cache
in the model layer for complicated queries for example. I think this bad
omission and hopefully will be added before the second printing.

He discusses two other enhancments. He address the N+1 problem and uses
database indexes. The N+1 problem is a very basic performance
enhancment. I think it should've been covered earlier in the text
because it is not a true performance technique in the sense of
implementing caching throughout an application. It does help with
performance, but I don't think it needs it's own section.

The book also considers pagination a performance enhancment. I don't
think this is a performance enhancment. Granted, it will increase
performance by cutting down the number of objects returned, but it seems
more of a usability thing than anything else. Pagination is very simple
and should be covered earlier on in the text. 

I can easily forget about the "Basic Performance Enhancements" chapter
because the "Engines" chapter is straigh GODLIKE. I think this chapter
is the best one in the book by good measure for a few resons:

1. It provides excellent documenation and guidelines for creating
   engines. This is hard to find at the time of this writing.
2. The chapter shows how to test and develop Rails engines correctly.
3. It demonstrates Capybara's raw power as a browser driver.
4. It makes you think about componentizing your application.
5. It shows you to release it as a gem. How many other books have you
   seen do this? It's this kind of thing that makes this book awesome.

The only downside is: it's god damn long. There is a ton of information
in this chapter. It doesn't feel long like the Authentication &
Authorization chapter. It just owns. If you want to learn about engines.
**Read this chapter**. It's that good.

The "Rack-Based Applications" chapter is nicely written. It opens the
hood to some of the undercover magic going on between Rails and the
webserver. It's a relativly short chapter, but does a nice job
introduction conepts and showing you how you can write the most basic
rack application. It shows you can you mount Rack applications in Rails
and most importantly introduces middleware. It would be nice to see a
real application of middleware, but it's hard to find one for a simple
application. The book shows how you can inject a peice of middleware to
jumble the links. Nothing serious really--just a proof concept. I'm not
sure what else the book could add to this chapter.

## Part 4: Wrapping Up

There are some interesting tidbits in the end, but nothing really worth
mentioning. The meat the book is the first 10 chapters. Things after
that become more complicated and therefore take more time to cover and
increase the scope of text. For instance: Deployment and designing an
API can be separate books. It's very hard to do them justice in a small
time frame. That being said, the first chapters are absolutely
fantastic! I think the first chapters do a wonderful job of teaching
people how to build basic rails application. This is by no means a guide
to building advanced applications but it will teach noobies how to get
going. 

## Who Should Buy This Book?

You should buy this book if you are a newbie with little to no knowledge
on Rails. This book will teach you everything you need to know to help
you start your journey. You will also become familar with some
intermediate concepts along the way. You will also learn it all test
first which will help you in the long run.

Finally Shoutout: To Ryan Bigg for letting my get in on the writing
process and helping him make his book better.

**You can buy the book [here](http://www.manning.com/katz/).**
