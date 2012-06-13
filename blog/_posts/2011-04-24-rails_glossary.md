---
layout: post
title: 'Learning Rails: A Glossary'
tags: [rails]
---

I've been teaching Rails to some people. One thing that's hard for them to
get straight is the large number of tools involved in Rails development.
This post is glossary of terms you may come across. Hopefully it will
clarify things for you.

## Acceptance Testing

Acceptancing testing is the act of testing use cases. Test cases are
written in a way that describes a use case. Then a test case is passing
it can be accepted. Cucumber is a good tool for acceptance testings.
Work with your stake holder to develop tests that represent use cases.
When the test is complete the feature should be accepted. Acceptance
testing is focused around people outside the code development accepting
features.

## Application Servers - Thin, Mongrel, Passenger, Unicorn

These are all application servers. They interact with your Ruby code and
respond to requests. They are integrated with web servers like Nginx or
Apache to server you application on the internet.

## Authentication

Authentication is the process of matching credentials to a person and
verifying them. Authentication is purely about identifiying who the user
is--and not what they can do. Devise is an example of an authentication
library.

## Authorization

Authorization is the process for determine what a specific user can do.
Authorization usually involves permission or role based systems. CanCan
is an example of an authorization library.

## Behavior Driven Development (BDD)

Is essentially the same as TDD except using a different set of tools to
express code in terms of user facing behavior. Rspec and Cucumber are
part of the BDD toolbox.

## Bundler

Bundler reads a Gemfile and calculates a set of version requirements to
make all the specified gems live happily together. It will prevent
version conflicts and infamous 'gem already activated error'. It allows
you to install git gems or standard gems from rubygems.org. It does not
require libraries, it simply makes them available. It is up to you
require them in your programs. Bundler can be used outside of rails. You
should use bundler when you do any ruby work.

## Capistrano

Capistrano is a tool for executing command one groups of remote (or
local) serves over SSH. It is primary used to deploy Ruby (on Rails)
application. It has support for multistage environments. Example,
staging and production. You can easily write your own tasks similar to
writing rake task. It is the preferred way deploy Rails applications.

## Capybara

Capybara is a gem designed to provide an abstraction layer between
different browser drivers. It is primarily used in integration testing to
interact with the web server. It provides an API to navigate between
pages, click buttons, fill in forms, and other user interactions. It has
adapters for many different browser drivers. Notable drivers include
Selenium, rack-test and webrat. 

## Compass

Compass is a library built around SASS abstractions. It provides mixins
for many common things like styling buttons and forms. It is also easy
to extend and comes with many built in functions. The blueprint CSS
framework is bundled by default.

## Cucumber

Cucumber is a test framework for creating plain english acceptance
tests. The tests can be executed automatically. Cucumber is used for
integration testing web applications. The test suite is often used in CI
(Continuous Integration). Cucumber uses a language called Gherkin to
parse files into lines and match them against regular expressions.
Regular expressions are matched with code blocks. Your test code lives
in these blocks.

Cucumber tests are divided up into "Feature" files. Each feature has
many "scenarios." Features are like use cases. Scenarios are different
permutations of that use case. Here is an example Feature file:

```gerhkin
Feature: Make Widthdrawls from Accounts
  As an account holder
  I want to use my money
  In order to use it buy thing

  Background:
    Given I have account under "RubyX"
    And my account is activated

  Scenario: There is enough money in my account
    Given my account has "$1,000"
    And I'm at the bank
    When I widthdraw "$500"
    Then my account should have "$500"

  Scenario: There is not enough money in my account
    Given my account has "$1,000"
    And I'm at the bank
    When I widthdraw "$500"
    Then the teller should reject my transaction
```

Here is an example step definition:

```ruby
Given /I'm at the bank/ do
  # set up pre conditions
end

Then /the teller should reject my transaction/ do
  # assert on things
end
```

## DSL

DSL stands for Domain Specific Language. They are crafted to solve one
or more problems very eloquently and nothing more. For example, a DSL
created to declare work order would be horrible suited for writing
Photoshop. DSLs are usually wrappers around more complicated methods
that make it easier to express the intent of the underlying code from
a programmer's perspective. You may have used a DSL before and 
not realized it. Here is an example from Sunspot's search 
functionality. It's designed for describing a search and nothing more:

```ruby
Post.search do
  fulltext 'best pizza'
  with :blog_id, 1
  with(:published_at).less_than Time.now
  order_by :published_at, :desc
  paginate :page => 2, :per_page => 15
  facet :category_ids, :author_id
end
```

## ERB

ERB is Embedded Ruby. ERB is built into the Ruby core. It allows to to
place Ruby inside other files. For example, placing Ruby inside HTML.
Here is an example:

```erb
<div class="<%= @ticket.state %>"
  <p><%= @ticket.message %></p>
</div>
```

## Factories - FactoryGirl & Machinist

These are two popular libraries for creating object factories. They are
usually used in test suites and population scripts. They provide a
default set of attributes and allow programmers to specify the
attributes they care about at creation time.

## Git

Git is a distributed version control system. Each user has a complete
copy of the repository. Changes can be pushed back to the remote
repositories for others to pull or push from. Linus Torvalds created Git
because he was unsatisfied with other version control systems like CVS
or SVN. Do not get GitHub confused with Git. GitHub is simply a service
for hosting the main Git repository. You can use git independent of
github, however most Ruby developers use github exclusively.

## HAML

HAML is an HTML abstraction language. It's great for structuring
documents and horrible to content. It will autoclose tags and lets you
specify attributes as a hash. You can also include ruby code inside
the templates. Here is an example:

    .post#post_5 
      .content= simple_format(@post.content)

## Heroku

Ruby PaaS (Platform as a Service). They provide free cloud hosting for
Rack applications with paid plans for increased resources. It is a very
easy way to deploy your first application. Beware, they are easily owned
by Amazon's AWS failure.

## Metaprogramming

Metaprogramming is a term for dynamically generating code at runtime.
Metaprogramming is why Rails feel the way it does. ActiveRecord
associations to dynamically add methods to your classed based on how to
declare them. Metaprogramming is possible in Ruby because it's a dynamic
language interpreted at run time.

## Open Classes & Monkey Patching

Ruby has open classes. This means you can simply declare methods insides
a class that's already been defined. ActiveSupport uses open classes to
add all those nice methods to core Ruby objects. This is how you can add
a method to the `String` class:

```ruby
class String
  def wtf?
    puts "wtf? " * self.length
  end
end
```

## Rake

Rake is like the Ruby version of make. You can create custom tasks that
can be executed from the command line. `rake db:migrate` is a classic
example. You can create as many tasks as you want. They can have
prerequisites. They can also be in namespaces. A ':' designates tasks in
different namespace. `db:migrate` means 'db' namespace, 'migrate' task.
Multiple tasks can be executed in one go like so: `rake db:create
schema:load`. They will be executed in the order they are listed. Rake
was originally designed to be like make, but is often used to execute
arbitrary code outside an application context. A cron job is a perfect
example.

## RJS (Ruby JavaScript)

RJS is an abomination. Don't use it. RJS uses ruby helpers to generate
JavaScript to dump into HTML attributes violating UJS.

## RSpec

Rspec is a unit testing framework. It is based around the idea that test
should describe behavior of classes in an english like way. Test files
are called "specs". Spec files are divided into "examples." Examples
contain matchers. Spec files can share examples. Here is an example
spec file:

```ruby
require 'spec_helper'

describe Post do
  it { should have_many(:comments) }

  describe "Post#out_dated?" do
    subject { Post.new :created_at => 2.months.ago }

    it { should be_outdated }
  end
end
```

## RVM

Rvm stands for Ruby Version Manager. It is a set of bash script designed
to allow you switch out Ruby interpreters on the fly. It manages
installed ruby interpreters and makes is very easy to install different
implementations. It also manages Gemsets. Gemsets are groups of gemsets
that are distinct from other groups (except the global gemset which
shares gems between different ruby interpreters).

## SASS & SCSS

SASS and SCSS are CSS abstraction languages. They are compiled down to
CSS. They allow you use variables, modules and include other files.
In short, they make it much easier to write and main large amounts of
CSS. 

## Selenium

Selenium is a library that simulates user interaction with a browser. It
runs the full browser. Selenium works best in FireFox, but can work in
Chrome and other browsers. Commands are sent across as JavaScript which
the browser evaluates to complete each action. Selenium is the most
complete solution for simulating a user for your web application.

## Test Driven Development (TDD)

The practice of writing a failing test first then completing the
implementation. This makes the developer spend more time thinking about
the code upfront while providing a solid test suite for the entire
application. You can use Test::Unit for TDD in Ruby.

## Test::Unit

Test::Unit is a unit test framework built into Ruby 1.8. It is known as
MiniTest in 1.9. It provides functionality for writing test cases with
standard setup and tear down. Rails generates test files built in
Test::Unit by default. It provides basic assertions. It's similar to
jUnit or any member of the xUnit family. Here is an example:

```ruby
require 'test_helper'

class PostTest < Test::Unit::TestCase 

  def test_out_dated? do
    post = Post.new :created_at => 2.months.ago
    assertTrue(post.out_dated?)
  end
end
```

## UJS (Unobstrusive JavaScript)

Unobtrusive JavaScript means separating JavaScript from the HTML.
Specifying an `onClick` attribute in HTML is consider obtrusive because
it obfuscates the markup. It is also hard to maintain because your
javascript is harder to maintain. You can do the same thing
unobtrusively by using jQuery to find the element by a class name and
applying a click handler. Essentially UJS means keep JavaScript in .js
files and HTML in .html files. Separation of church and state if you
will.

## Webrat

Webrat is the original headless browser. It's similar to selenium, but
much more implemented. It does not execute JavaScript and does not
execute in a GUI. It is the most basic driver and is perfect for
interacting with simple websites.
