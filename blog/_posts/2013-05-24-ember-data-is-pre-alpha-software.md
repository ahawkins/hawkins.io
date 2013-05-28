---
layout: post
title: "Ember Data Is Pre-Alpha Software"
tags: [ember, javascript]
---

I decided to commit to Ember Data because of it's value
promise. I think that ember data is going to change the way we write
web applications. However we're not there yet. Ember Data is still
undergoing development. The project does not have formal releases.
It's not even alpha software at this point--it's simply SHA's. The
leaders of the Ember project have correctly decided to put up
warnings about it. However I don't think those warnings are strong
enough (or we has a society are horrible at obeying signs). This post
is for those of you are (for whatever reason) considering using Ember
Data.

I think I have a pretty high debugging tolerance. Most of the time don't mind having
to debug other peoples code. It's fun in its own weird way to open
their code in an editor and poke around. It's also fun to solve
problems in other's code. If you choose to use ED today you will spent
a fair amount of time debugging ED internals. This is simply a fact of
life. There is going to be weird errors. My coworker and I spent two
days debugging a series of issues all related to a missing error
handler on the end of promise chains. I immediately opened a [PR](https://github.com/emberjs/data/pull/995)
once we knew the root cause. This PR has been merged. This will
prevent people from wasting their time like we did.

We were lucky we were able to debug our problems. I'm knowledgeable
about ED's internals. I know about the different parts. I know where
problems are likely to originate. But you probably don't. Maybe you
just want to try it out. That's fine, just don't expect anything to
work--at least not without some work on your part. If you want things
to work you'll have to take some time to learn and understand ED's
architecture. Would you got involved with Rails if you were required
to understand and be able to hack on it's internals?

ED is a very ambitious project. It's attempting to solve something
that's never been done in the browser before. I think it's going to
fundamentally change the way we right applications. There are many of
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

If you are ok with all of those, I think you may find ED
interesting--especially if you're willing to try it out. If you are
not ok with any of them then simply wait. Don't get involved with it
if you're not willing to accept the responsibilities and risks.
