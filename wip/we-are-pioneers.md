My company decided to move to a client side application in November 2011.
We hit the limit of keeping the UI consistent across the application
using jQuery and server side generated javascript. I'd been following
Sproutcore 1.5/2/Amber/Ember's development for about 6 months before
hand. I knew and respected Yehuda's work. I met Tom Dale at some
Sproutcore meetups. Tomhuda had a proven track record of open source
development. They wanted to build ambitious web applications. So did
we.  Yehuda [announced](http://yehudakatz.com/2011/12/08/announcing-amber-js/)
Amber on December 12, 2011. The timing was perfect. We made the
decision. We would bet our product's success on Yehuda, Tom, and
Ember.js. Little did we know we were entering a whole new world where
nothing free with very little infrastructure.

It has been an extremely rough and tiring road. We've ridden the
endless release treadmill, dealt with breaking changes with every
other commit, and a host of other issues. I honestly had no idea what
I was getting into. In school they teach us about the first colonists
who came from England (err Vikings) and settled North America. That
was some tough shit. There was nothing. There was no infrastructure.
If you needed it, you build it. This is what it was like.

I came from Rails. Rails was extremely mature even 2.5 years ago. Ruby
itself is a wonderful and mature language. The tooling is fantastic.
This is due largely, in my opinion, to rail's meteoric success and
driving probably hundreds of thousands of people to ruby. Having that
many users is going to create a very vibrant and powerful ecosystem.
This was the developed world. Then I arrived on javascript island,
fresh off the boat with anticipation, excitement, passion, and ton of
other positive adjectives. I was ready for a new adventure. It was a
whole new world.

We quickly hit the first road block. There was no one for the brand
new job position of "javascript application developer". I say
"javascript application developer" because there is a huge difference
between someone who: understand design patterns, take testing
seriously, and can architect complex applications vs someone strings
together jQuery plugins for DOM manipulation. There was a significant
talent drought at that point in time. Backbone had been out for about
a year. I don't think the web development community was ready for a
huge shift in javascript development. Javascript engineers are getting
better every day. It takes time for communities to learn these things.
Imagine Ruby 10 years ago. It's an entirely different beast then it is
now. I started the development while we looked for people.

This was a very difficult process. There was no documentation and
there were virtually zero other users. I don't know how anyone learned
how to use Ember at this stage. It still baffles me that people were
able to ship code! Downright shocking and impressive in its own way.
We struggled along until we hit the next major problem: the actual god
damn act of programming the fucking thing.

At the time of this writing there are multiple build tools. You may
know Yeoman, Brunch, or even Iridium. There was a time before these
things. Take a step back and thing of all the
things you need to develop a decent app at scale:

1. CSS preprocessing
2. CoffeeScript. You may not like it but I love it.
3. Module wrapping: it only make sense to keep code in separate files.
4. Template handling
5. Template precompilation. If you care about speed and 
  mobile then you must precompile templates.
6. Asset concatenation. No one is going to make 500 network requests
  to load all the assets.
7. Asset minification
8. Different environment support. Things behave differently when
  you're developing, testing, and in production.
9. Some sort of test framework / runner / something. You need
  something to ensure the damn thing actually works.
10. A decently fast dev server. Reload and look at the app again. The
  only acceptable way to develop a web application.

There are some other nice things to have like: spriting, file
generators, and icon font generation. Either way, the build tool must
wrap all of those things one easy to use package. This space was
relatively new at the time. Brunch's initial commit was 2011-01-19.
Rake-Pipeline was 2011-10-06. Yeoman this year. There was no good tool
right around the turn of 2012. I liked rake-pipeline. It did not do
all of the things I needed but it did provide a very solid foundation
for asset compilation and generation. Since this is a brave new world
I did what any self respecting pioneer would do. I built it that shit.
[Frontend Server](/asf) was announced on 2012-02-20. This was just
enough get our team off the ground. 

# NOTE: Revise this paragraph
We ran into problems as time went on. FrontendServer didn't scale and
their was no easy way to do tests. I took a long hard look at the
problem. I built [Iridium](http://github.com/radiumsoftware/iridium).
Iridium made it possible to actually sit in our editors and write the
application. Iridium is without a doubt my favorite bit of code I've
ever written. However there was another problem. I spent so much time
and effort simply writing the tools we needed to take the next step. I
took to road to try to share with people what was happening in this
space. I blogged about it, spoke about it at user groups all over
Europe, and conferences. Just trying to get the message out. Speaking
at in Helsinki & Paris were my favorites. I spoke at Reject.js in
Berlin about client side application testing. The messages was we
have so much further to go but we can get there. I simply wanted
people to know what it was like to be in the position--that it's
really not so great but there are people pushing the boundaries. We
are pioneers after all.

[Paul Cowan](http://twitter.com/dagda1) and I were finally ready to
start heads down development starting in December 2012 after months of
work on Iridium and other failed starts. This was just
around Ember's official one year birthday. Then we hit the next wall. Iridium
could run tests in the abstract, but we had no idea to actually test
the ember application. Of course there was nothing. So we had to build it.
There were I think 3 or 4 people active in this area. 
There was us, [Paul Chavard](/https://twitter.com/tchak13),
[Jo Liss](/https://twitter.com/jo_liss) and [Erik Bryn](http://twitter.com/ebryn).
We setup full integration/acceptance tests and unit
tests. We pushed very hard for a "reset" method and other things
required to make ember more TDD friendly. We shared our working
implementation and I think some of our ideas made it into the current
ember-testing package. Ember-Testing was released in one of the RCs.
It would not have been possible without the everyone's hard work
around this time period. I'm not sure how much people take in their
current development environment for granted. It's very hard to build
up a new platform from scratch. It feels good to be on the edge
pushing the boundaries but it's also very painful at times. This is
life on the edge.

My team and myself have been using Ember since the dawn of time. We've
somehow managed to survive all the various versions. There was version
"0.9.8". It sounds so tantalizing close to 1--so tantalizingly close
to being done. That is simply not the case. It was so far off on
it's value promise. Then there was Ember-Data. If you thought Ember was
bad for breaking changes and upgrading, then ember data would drive
you insane. Try going from ED revision 4 to revision 10. There was simply no fucks
given about ED. Ember has been developing quite rapidly and the
concepts were clear. Ember Data was like code on a desinger's
sketchpad. Things would get erased and moved around without an afterthought.
Such is life. We were figuring out what needed to be. Then
the prereleases came. Now the RC's are coming. We're on RC5 right
now. I think we'll probably see RC 8, 9, or *even* 10 before serious
considerations are made of 1.0. This seems wrong in hindsight. If you
need multiple prereleases and a ton of release candidates, perhaps you
should wait until the core offering as settled.

I'm sitting here looking back on where we came from and where we're
going. 1.0 is coming up. It will come eventually. Unfortunately it's
lacking some things. I find the lack of radio buttons to be undeniable
hilarious. It's simply embarrassing. Ember is "a framework for ambitious
web applications" as long as the ambitions don't include using radio
buttons. I'm going to dedicate some time to making sure this doesn't
happen. This week [Alex Matchneer](http://twitter.com/matchy)'s async router PR was merged.
This was most critical merge I think we've had in a long time. The new
router has been undergoing changes ever since it was merged. I think
it's still taking a long time to reach feature parity with the old
router. At least we can finally make authenticated apps on the client.

I guess the question is "What does 1.0 mean?" I don't know anymore.
The version numbers mean nothing to me because we use master ember and
master ember-data. I just recorded an episode of the [Ember
Hotseat](http://emberhotseat.com). I mentioned that Ember was somewhat
of a shining city on a hill. It was a bastion of hope. Ember was going
to revolutionize client side development in the way Rails did
thousands for PHP developers. I think 1.0 is our first real stab at
building this city. Rome wasn't built in a day people. Rome sure as
fuck wasn't built in 2 or 3 years either.

There are lot of poeple migrating from backend to frontend. I was
(wrongly) looking for a silver bullet. This was a major fail on my part.
Hindsight is always 20/20. I know others are thinking the same thing.
They think, I'll just switch to X and boom. Everything is fixed. [Trek
Glowacki](https://twitter.com/trek) and I were having a conversation about the entire Ember and
JS ecosystem. He described the situation perfectly. **Ember is like
Rails. Rails 0.51**. Let that sink in for a minute. How many of you
were around Rails in the early days? Shit was hard. How many years has
it taken Rails to become what it is now. Rails is rock solid. I
**badly** want this for Ember. I want that ecosystem. I want the framework
to enjoy those levels of success. I want using Ember to make people
happy and productive in building ambitious web applications.

The fact of the matter is that I don't enjoy building these
applications a lot of the times. It's god damn difficult. It's not
entirely because of Ember. Ember works amazingly at its core. Then
there is Javascript itself. I'm not talking about Node. I'm talking
about browser javascript. Can a man get a package manager for fuck's
sake? Browser javascript leaves so much to be desired. This is why we
have things like Bower and other build tools--simply because we need
to manage the JS and compile/concatenate it ourselves. These are
workarounds. They are not solutions. I hope we can change this.

Ember's community is small but **intensily** passionate. I haven't
seen this much dedication in a group of people before. I think that's
because we share pioneering spirit and a common goal. We are all
working together to do something that hasn't been done before. We are
leveling up the web platform. I have this picture in my head. The
Ember core team and other key contributors have just landed in
motherfucking Jamestown, Virginia after being some of the first
settlers to cross the Atlantic. We've been actively colonizing our
small city building up on core concepts. We've been making everything
we need to simply survive in this new world. We can handle URL's,
update views, and manage data in remote sources. This is enough to
build a foundation. More and more people are coming into Jamestown
from other major places like .NET and Java. We're in a melting pot
trying to making it all work. Yehuda has left the colony for the true
wilderness: TC9 and future versions of Javascript. He's like Lewis and
Clark. He's working on Web Components and other things that simply so
far out in the future. Hopefully he'll come back with knowledge and
tools for us back in the colony In the meantime we will be here,
working hard--building up our Rome. Some of us actively working on
Ember-Data (which I believe is single most important part of the whole
thing since applications are nothing without data). Others will work
on animations, validations, package managers, plugin ecosystems, and
god knows what else. You need to build a foundation before you can
build a mansion.

There are a few things that scare me and excite me about this analogy.
We knew what America came. It sure took a shit load to
get there. How many people died during colonization? (Read get burned
out, exhausted, or simply collapse under the difficulty). Then there
was the civil war and other conflicts (Read internal
disagreement about what to do / where we're going over our future).
Then I think to myself look America became. There were people who
believed in a vision of a new world and who had the pioneering spirit to build
it. The community has years to go to get to achieve shining city on a
hill status. I think America became so much more than the initial
settlers thought it could be. This excites me. Perhaps we can change
the web beyond our wildest dreams. After all, we are pioneers and can
make it happen.

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
