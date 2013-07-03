---
layout: post
title: "We are Pioneers"
segment: ember
---

There have been a few times in history where we've really pushed the
boundaries. The 16th and 17th century are prefect examples. Europeans
began to colonize North America. Settlers were promised a better life,
a fresh start, and the chance to start a new country. This was extremely
tough work. Many earlier settlers died. They didn't have the
luxuries they had back home. They had to built houses, 
roads, and entire cities from scratch. I think a lot of the very
early colonists had a vision of a better place and many of them had
the will power to make that happen.

I started a Rails contract in February 2010. Rails 2 was stable and
standard at the time. There was nothing revolutionary at this point
but it got the job done. There was nothing to argue about. That was
the decision and we went with it.

Fast forward to October 2011. Jeremy Askenas releases the initial
version of Backbone. A new wave of settlers comes to the developing
world of client side applications. Suddenly there are many new
problems. The Backbone community plants their flag and takes hold of
the emerging market. They continued to settle the new world while we
sat in our comfortable world on the server.

It's November 2011. Our product had not gained the traction we wanted.
We'd reached the limits of what we could accomplish of using basic
jQuery and server generated javascript. We needed to move to a
dedicated full client side application. This was the only way to build
an application that was fast, responsive, and next level.
Backbone was somewhat established at this time. Its capabilities
were well know. However it wasn't enough for us. We needed data
binding and a real data story--a more complete solution. The Backbone
community had pioneered what could be done at that level, but it was
time for the next major wave of settlers.

I'd been involved with Sproutcore's (also another early and successful
pioneer in this space) development for a while. I knew Tom Dale
and Yehuda Katz were working on the next version. It seemed
they were working on future technology. They made big promises about
developing ambitious web applications. We felt we had a very ambitious
application. Yehuda [announced](http://yehudakatz.com/2011/12/08/announcing-amber-js/)
Amber (which was renamed to Ember) on December 12, 2011.
The timing was perfect. We made the decision. We would bet our
product's success on Yehuda, Tom, and Ember. Little did we know we
were entering a whole new world.

We did not know what we were getting in to. I had no idea it would be
as difficult as it was. I bet there were plenty early American
settlers thought the exact same thing. Everything makes sense in
hindsight, but we really no clue how much effort it would take. We've
ridden the endless release treadmill, dealt with breaking changes with
every other commit, and a host of other issues.

We faced the same issues any developing community experiences: lack of
good developers and a very small ecosystem. We had a very hard time
finding competent engineers who could work in the new paradigm. There
were no plugins or other libraries to use. You downloaded the
javascript file and built everything yourself. We are pioneers so this
is what we had to do.

I spent a significant amount of time writing
[Iridium](http://github.com/radiumsoftware/iridium) after many
previous attempts. There was nothing to make the actual development
experience bearable. You may be thinking: Adam, why didn't you just use
Yeoman? Because this was almost a year ago. There was no such thing as
Yeoman then. We needed to work now, not at some unknown point in the
future. This is life on the frontier. You have to take care of
yourself. No one is going to do it for you. This was a prerequisite,
we really couldn't build anything serious until we had this.

Then there is the ecosystem problem. There is still not a large
ecosystem around Ember. There is no vibrant set of plugins making
everyone's life easier. Javascript applications require data. We
chose to use Ember-Data. This was the only game in town in the
beginning. This was a major pain point which has really been beaten to
death across the internet. Maybe you're thinking, how come you didn't
use ember model or straight ajax? For one, ember-model wasn't around
at the beginning of 2012, or the middle, or the end. This is another
case of build the best you can with the tools you have at the time.

[Paul Cowan](http://twitter.com/dagda1) and I were finally ready to
start heads down development in December 2012. This was just
around Ember's official one year birthday. Then we hit the next wall.
No one had any damn idea on how to test these applications.
Of course there was nothing. So we had to build it: test runners,
testability into the framework, and everything else.
There were I think 3 or 4 people active in this area.
There was us, [Paul Chavard](/https://twitter.com/tchak13),
[Jo Liss](/https://twitter.com/jo_liss) and [Erik Bryn](http://twitter.com/ebryn).
We setup full integration/acceptance tests and unit
tests. We pushed very hard for a "reset" method and other things
required to make Ember more TDD friendly. We shared our working
implementation and I think some of our ideas made it into the current
ember-testing package. Ember-Testing was released in one of the RCs.
I'm not sure how much of well established development toolchains like
Java, Python, or Rubies are taken for granted. It's very hard to
build up a new platform from scratch. It feels good to be on the edge
pushing the boundaries but it's also very painful at times.

I'm very reflective by nature. Ember 1.0 is quickly
approaching. I ask myself: what did we accomplish and what is there
left to do? I used to think that having a 1.0 release would solve all
our problems. The API's would settle and the framework would approach
feature completeness. Now I think the 1.0 just means: we won't break
stuff for a while. Sure the framework's API will settle but that does
not solve the larger problem's the community is facing.

I've seen these problems before. I started with Rails in 2006. It was
difficult in the earlier years. It has only really matured in the past
3 years. I think Rails 3.1 really embodies everything you need to
make a certain class of web applications. Ember and its ecosystem are
so far off. I was speaking to [Trek Glowacki](http://twitter.com/trek)
about all the issues we're facing. He described it perfectly.

> Ember is like Rails. Rails 0.51.

This does not imply either project is bad. It implies a level of rapid
change as the framework and ecosystems evolved. This is the first time
in internet history that we're trying a full browser application.
We'll continue to learn more as we make mistakes and figure out what
works. Everything learned in the early releases sets the stage for the
later ones. Rail's REST support is a perfect example. It was not there
in the beginning. Now it's there and you can't build a Rails app
without REST. The comparison also made something painfully clear: 
**it's going to take 3-4 years to get this right.**

Ember is about big promises and ambitions. It's a
long bet. I just recorded an episode of the [Ember Hotseat](http://emberhotseat.com/2013/06/26/ember-hot-seat-episode-003.html).
I mentioned that Ember is shining city on a hill. It
was a bastion of hope. Ember was going to revolutionize client side
development in the way Rails did thousands for web developers. I think
1.0 is our first real stab at building this city.

Ember's community is small but **intensily** passionate. I haven't
seen this much dedication in a group of people before. I think that's
because we share pioneering spirit and a common goal. All of us
work together to do something that hasn't been done before. We are
leveling up the web platform. The Ember core team and other key
contributors have just landed in the new world. We're
building our own colony using the work of previous people (like the
Backbone community). We've been colonizing our small city
building up on core concepts and abstractions. We've been making
everything we need to simply survive. We can handle
URL's, update views, and manage remote data sources. This is enough
to build a foundation. It's the first step. More and more people are
coming over from other major places like .NET and Java. We're in a
melting pot trying to making it all work. Yehuda has left the colony
for the true wilderness: TC39 and future versions of Javascript. He's
like Lewis and Clark rolled up into one. He's working on Web
Components and other things that are so far in the future.
Hopefully he'll come back with knowledge and tools for us back in the
colony. In the meantime we will be here, working hard--building up
the new world. Some of us actively working on Ember-Data (which I
believe is the most important because javascript applications require
data). Others will work on animations, validations,
package managers, plugin ecosystems, and god knows what else.
Hopefully at some point in the future we can all share a beer and
the satisfaction of knowing we simply did it.

I think back to the early American settlers and what America became.
It's intimidating. How many people died settling the country? It
took slaves to build up economies. There was a civil war, two world
wars, and other wars. Are we going to have our own wars? How many good
developers are simply going to burn out putting up with all the crap
that comes from building up a new platform? Only time will tell. On
the other hand I think we can agree the American experiment spawned an amazing
country. This is terribly exciting to me because it gives me hope and
inspires me that, yes, we can change the web beyond our wildest
dreams. We are pioneers after all.

I'd like to call out some people for all their hard: Yehuda Katz, Tom
Dale, Erik Bryn, Paul Chavard, Stefen Penner, Kris Selden, Luke Melia,
Peter Wagenet, Kasper Tidlemann, Jakub Arnold, Trek Glowacki, Joachim
Haagen Skeie, Igor Tezic, Robin Ward, Sami Asikainen, Jeff Atwood,
Alex Matchneer, Paul Cowan, Joshua Jones, Piotr Sarnacki, Gordon
Hempton, Dudley Flanders, Devin Torres, Ryan Florence, Andy Leeper,
Brian Cardella, James Rosen, and everyone else who has submitted a PR
to Ember or Ember Data. All of these people have contributed something
and their efforts do not go unnoticed or unappreciated.
