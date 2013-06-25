There have been a few times in history where we've really pushed the
boundaries. The 16th and 17th century are prefect examples. England
began to colonize North America. Settlers were promised a better life,
a fresh start, and the chance to start a new country. This was extremely
tough work. Many of the earlier settlers died. They didn't have the
luxuries they had back home. They had to built their own houses, their
own roads, and entire cities from scratch. I think a lot of the very
early colonists had a vision of a better place and many of them were
willing to make that happen.

I started a Rails contract right at the start of 2010. Rails 2.3 was
very comfortable at time. This was the way to build web applications
and it worked well. There was nothing revolutionary at this point but
it got the job done in a consistent fashion. There was nothing to
argue about. That was the decision and we went with it. We wanted to
build a rich user interface and we could do that using technology we
had a time.

Fast forward to Ocotober 2011. Jeremy Askenas releases the initial
version of Backbone. A new wave of settles comes to the developing
world of javascript applications in the browser. All of a sudden there
are a ton of problems to solve from this brand new situation. The
backbone community plants their flag and takes hold of an emerging
market. They continued to settle this new world while we sat in our
comfortable Rails environment.

Fast forward to November 2011. Our product had not gained the traction
we wanted. We'd reached the limits of what we could accomplish of
using basic jQuery and server generated javascript. We knew that we
needed to move to a dedicated full client side application. This was
the only way we could solve our problems and make the product we
wanted. Backbone was a thing at this point. It's capabilities where
well know at this point. However it wasn't enough for us. We wanted
data binding, data support, and a more complete solution. The Backbone community had
pioneered what could be done at that level, but it was time for the
next major wave of settlers.

I'be been involved with Sproutcore's (also another early and successful
pioneer in this space) development for a while. I knew that Tom Dale
and Yehuda Katz were working on the next version. It really seemed
they were working on future technology. They made big promises about
developing ambitious web applications. We felt we had a very ambitious
application. Yehuda [announced](http://yehudakatz.com/2011/12/08/announcing-amber-js/)
Amber (which was renamed to Ember.js) on December 12, 2011.
The timing was perfect. We made the decision. We would bet our
product's success on Yehuda, Tom, and Ember.js. Little did we know we
were entering a whole new world.

We did not know what we were getting in to. I had no idea it would be
as difficult as it was. I bet there were plenty early American
settlers thought the exact same thing. Everything makes sense in
hindsight, but we really no clue how much effort it would take.
It has been an extremely rough and tiring. We've ridden the
endless release treadmill, dealt with breaking changes with every
other commit, and a host of other issues.

We faced the same issues any developing community experiences: lack of
good developers and a very small ecosystem. We had a very hard time
finding compotent engineers who could work in the new paradigm. There
was also no plugins or other libraries to use. You downloaded the
javascript file and built everything yourself. We are pioneers so this
is what we had to do.

I spent a good 4 months developing
[Iridium](http://github.com/radiumsoftware/iridium) after many
previous attempts. There was nothing to make the actual development
experience bearable. You may be thinking: Adam, why didn't you just use
Yeoman? Because this was almost a year ago. There was such thing as
Yeoman then. We needed to work now, not at some unknown point in the
future. This is life on the frontier. You have to take care of
yourself. No one is going to do it for you. This was a prerequisite,
we really douldn't buit anyhting serious until we had this. You gotta
build a fire if you need to cook.

Then there is the ecosystem problem. There is still not a large
ecosystem around Ember. There is not vibrant set of plugins making
everyone's life easier. Everyone need's data in their application. We
chose to use Ember-Data. This was the only game in town in the
beginning. This was a major pain point which has really been beaten to
death across the internet. Maybe you're thinking, how come you didn't
use ember model or straight ajax? For one, ember-model wasn't around
at the beginning of 2012, or the middle, or the end. This is another
case of build the best you can with the tools you have at the time.

[Paul Cowan](http://twitter.com/dagda1) and I were finally ready to
start heads down development starting in December 2012. This was just
around Ember's official one year birthday. Then we hit the next wall.
No one had any damn idea on how to test these applications.
Of course there was nothing. So we had to build it: test runners,
testability into the framework, and everything else.
There were I think 3 or 4 people active in this area.
There was us, [Paul Chavard](/https://twitter.com/tchak13),
[Jo Liss](/https://twitter.com/jo_liss) and [Erik Bryn](http://twitter.com/ebryn).
We setup full integration/acceptance tests and unit
tests. We pushed very hard for a "reset" method and other things
required to make ember more TDD friendly. We shared our working
implementation and I think some of our ideas made it into the current
ember-testing package. Ember-Testing was released in one of the RCs.
I'm not sure how much people take in their current development
environment for granted. It's very hard to build up a new platform
from scratch. It feels good to be on the edge pushing the boundaries
but it's also very painful at times.

I'm very reflective person by nature. Ember 1.0 is quickly
approaching. I ask myself: what did we accomplish and what is there
left to do? I used to think that having a 1.0 release would solve all
our problems. The API's would settle and the framework would approach
feature completeness. Now I think the 1.0 just means: we won't break
stuff for a while. Sure the framework's API will settle but that does
not solve the larger problem's were facing as a community.

I've seen these problems before. I started with Rails in 2006. It was
difficult in the earlier years. It has only really matured in the past
3 years imo. I think Rails 3.1 really embodies everything you need to
make a certain class of web applications. Ember and it's ecosystem are
so far off. I was speaking to [Trek Glowacki](http://twitter.com/trek)
about all the issue's were facing. He described it perfectly.

> Ember is like Rails. Rails 0.51.

I was able to connect everything once he said that. I'd been there and
lived that. I remembered what it was like. That's when I accepted that
we were infants in a new world even though we'd been at this for over
a year. It also made another thing painfully clear: **our mission is
going to take years.**

What is our mission anyways? That's a damn good question. Initially
for my team it was just to build an app. It's always been "change the
way we make applications" for me. Ember is about big promises. It's a
long bet. I just recorded an episode of the [Ember Hotseat](http://emberhotseat.com). 
I mentioned that Ember was somewhat of a shining city on a hill. It
was a bastion of hope. Ember was going to revolutionize client side
development in the way Rails did thousands for PHP developers. I think
1.0 is our first real stab at building this city. Rome wasn't built in
a day people. Rome sure as fuck wasn't built in 2 or 3 years either.

Ember's community is small but **intensily** passionate. I haven't
seen this much dedication in a group of people before. I think that's
because we share pioneering spirit and a common goal. We are all
working together to do something that hasn't been done before. We are
leveling up the web platform. The Ember core team and other key
contributors have just landed after crossing the Alantic. We're
building our own colony using the work of previous people (like the
Backbone community). We've been actively colonizing our small city
building up on core concepts and abstractions. We've been making
everything we need to simply survive in this new world. We can handle
URL's, update views, and manage data in remote sources. This is enough
to build a foundation. More and more people are coming over from other
major places like .NET and Java. We're in a melting pot trying to
making it all work. Yehuda has left the colony for the true
wilderness: TC9 and future versions of Javascript. He's like Lewis and
Clark. He's working on Web Components and other things that simply so
far out in the future. Hopefully he'll come back with knowledge and
tools for us back in the colony In the meantime we will be here,
working hard--building up our Rome. Some of us actively working on
Ember-Data (which I believe is single most important part of the whole
thing since applications are nothing without data). Others will work
on animations, validations, package managers, plugin ecosystems, and
god knows what else. Then hopefully at some point in the future we can
all look back and simply say: we did it.

I think back to the early American settlers and what American became.
It's intenesly intimidating. Many people died settling the country. It
took slaves to build up economies. There was a civil war, two world
wars, and other wars. Are we going to have our own wars? How many good
developers are simply going to burn out putting up with all the crap
that comes from building up a new platform? Only time will tell. On
the other hand I think we can agree the American spawned an amazing
country. This is terribly exciting to me because it gives me hope and
inspires me that, yes, we can change the web beyond our wildest
dreams. After all, we are pioneers and can make it happen.

I'd like to call out some people for all their hard work in settling
the new world: Yehuda Katz, Tom Dale, Erik Bryn, Paul Chavard, Stefen
Penner, Kris Selden, Luke Melia, Peter Wagenet, Kasper Tidlemann,
Jakub Arnold, Trek Glowacki, Joachim Haagen Skeie, Igor Tezic, Robin
Ward, Sami Asikainen, Jeff Atwood, Alex Matchneer, Paul Cowan, Joshua
Jones, Piotr Sarnacki, Gordon Hempton, Dudley Flanders, Devin Torres,
Ryan Florence, Andy Leeper, Brian Cardella, James Rosen, and everyone
else who has submitted a PR to Ember or Ember Data. All of these
people have contributed something and their efforts do not go
unnoticed or unappreciated.
