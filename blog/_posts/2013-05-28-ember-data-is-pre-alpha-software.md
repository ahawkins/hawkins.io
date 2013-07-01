---
layout: post
title: "Ember Data Is Pre-Alpha Software"
tags: [ember, javascript]
segment: ember
---

I decided to commit to Ember Data because of it's value
promise. I think that ember data is going to change the way we write
web applications. However we're not there yet. Ember Data is still
under rapid, heavy, and usually with breaking changes. ED's github
project page has a warning banner. It states this. I think many people
are unsure of how _strong_ the warning is. This post is for those of
you are are (for whatever reason) considering using or getting
involved with Ember Data.

I think I have a pretty high debugging tolerance. Most of the time
don't mind having to debug other peoples code. It's fun in its own
weird way to open their code in an editor and poke around. It's also
fun to solve problems in foreign code. If you choose to use ED today
you will spent a fair amount of time debugging ED internals. This is
simply a fact of life. There is going to be weird errors. My coworker
and I spent two days debugging a series of issues all related to a
missing error handler on the end of promise chains. I immediately
opened a [PR](https://github.com/emberjs/data/pull/995) once we knew
the root cause. This PR has been merged. This will prevent people from
wasting their time like we did. The PR made it into the first official
release of ember data announced [today](http://emberjs.com/blog/2013/05/28/ember-data-0-13.html).
Now you guys won't get burned like I did.

We were lucky we were able to debug our problems. I'm knowledgeable
about ED's internals. I know about the different parts. I know where
problems are likely to originate. But you probably don't. Maybe you
just want to try it out. That's fine, just don't expect anything to
work--at least not without some work on your part. If you want things
to work you'll have to take some time to learn and understand ED's
architecture. 

ED is a very ambitious project. It's attempting to solve something
that's never been done in the browser before. I think it's going to
fundamentally change the way we write applications. There are many of
use out there who believe in the project. At this point it requires a
very special type of person to get involved. You have to accept the
risk of using pre-alpha software. These are the decisions I had to
make:

1. You are comfortable building form source (How many of you would only
   install something if it's in homebrew?)
2. You are willing to actually spend time understanding ED's internals
   to the point where it's like your own code.
3. You are willing to give constructive feedback and fix bugs you find
4. You understand the previous 3 points and accept that will be much
   harder and painful than you expect.

If you can commit to those points and the inherent risks of using
early stage software then I recommend you check out ED.  If you are
not ok with any of them then simply wait. Don't get involved with it
if you're not willing to accept the responsibilities and risks.

Luckily the Ember Data core team and other contributors are aware of
the issues facing the project. They have refocused their effors over
the past few weeks. [Stefan Penner](https://github.com/stefanpenner/)
has done some great work implementing promises inside ED. I'm hoping
to work with him in the coming weeks to implement promises in other
parts of the architecture. I'm primarily focused on improving the
greenfield experience. I think many users have heavily customized
setups. They are far removed from the out of the box experience. I'd
like to improve the developer friendliness so newcomers don't give up
in frustration. [Paul Chavard](https://github.com/tchak) is always
hard at work improving ED's feature set. He's been working on adding
real server side validation handling to ED for some time. [Igor
Terzic](https://github.com/igorT) is also helping out a bunch. Of
course Tom and Yehuda are involved as well. The team is meeting
biweekly to discuss what needs to be done. Hopefully this and quick
public releases will really move the project forward. None of us can
wait for the day when we can release Ember Data 1.0--hell even
1.0-beta1. We need all the help we can get to make it though. We need
people, willing to accept the risks and responsiblities, to help us
find bugs and improve the core concepts. We will get there. Give us
time and we'll show you.

Discuss on [Hacker News](https://news.ycombinator.com/item?id=5786212).
