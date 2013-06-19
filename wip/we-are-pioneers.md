This is a post about how I feel. It is an emotional post because it
focus on issues that are very important to me, my career, and pretty
much everything I work towards.

I've been in this whole "single page application", "browser
application", "client app" scene for a long time now. My manager and I
decided to split our Rails 2.3 app into a client and a server. The
existing android app, iphone app, and now browser app would talk to
one single thing: the api. Every application would have it's own repo.
Development would happen by separate teams at whatever pace the
specific application dictated. This was a pretty huge thing for us
because we were on massive rails app maintaing UI state with a shit
load of jQuery things and `js.erb` templates to return new HTML for
every single aspect of the site. We chose to do this because we did
not want to build a product we weren't proud of. Also it simply became
impossible to develop new features and keep the UI insync across all
pages. We made this decision in **November 2011**.

I had been involved with Sproutcore for a few months before hand.
Yehuda Katz announced he would be living the rails world to work on
then what was going to be Sproutcore 2. History tells us that
Sproutcore 2 became Amber, then quickly Ember. Amber was
[announced](http://yehudakatz.com/2011/12/08/announcing-amber-js/) on
2011-12-08. The post states he'd been working on this for about a
year. Fast forward to now: 1.5 years later. So perhaps 2.5 years of
work on what became Ember.js today. I'd scene the mobile me or
whatever app Apple built in Sproutcore and was impressed. I knew this
was the future. I like the sproutcore's concepts, but working with the
view system was not for me. Tom and Yehuda made the right choice going
with HTML, CSS, and Handlebars. This is still the right choice today.
Ember was always billed as the future. It was the framework for
ambitious web applications. It was with that, that I decided to stake
our success on Tom and Yehuda's ideas.

It has been an extremely rough and tiring rode. I've ridden the
endless release treadmill, dealt with breaking changes with every
other commit, and a host of other issues. I honestly had no idea what
I was getting into. In school they teach us about the first colonists
who came from England (err Vikings) and settled North America. That
was some tough shit. There was nothing. There was no infrastructure.
If you needed it, you had to build it. This is what it was like.

I came from Rails. Rails was extremely mature even 2.5 years ago. Ruby
itself is a wonderful and mature language. The tooling is fantastic.
This is due largely, in my opinon, to rails meteoric sucess and
driving probably hundreds of thousands of people to the ruby platform.
Having that many users is going to create a very vibrant and powerful
ecosystem. This was the developed world.

Then I arrived on javascript island, fresh off the boat with
anticipation, excitement, passion, and ton of other positive
adjectives. I was ready for a new adventure. It was a whole new world
that we could dive into.

Then we hit our first road block. It took us a long time to find
competent Javascript Software Engineers. I say "Software Engineer"
because there is a huge difference between programmers who: understand
design patterns, take testing seriously, and can architect complex
applications vs programmers who know how to string together jQuery
plugins for DOM manipulation. There was a significant talent drought
at that point in time. Backbone had been out for about a year (which
has its own problems at scale) and node for a while as well. I don't
think the Javascript community as whole had enough time to level up. I
think more and more talented engineers are coming from the Javascript
community. It takes time for communities to learn these things.
Imagine Ruby 10 years ago. It's an entirely different beast then it is
now. Since we couldn't find anyone I set out to learn the framework
and try to prototype some stuff.

This was a very difficult process. There was no documentation and
there were virtually zero other users. I don't know how anyone learned
how to use Ember at this stage. It still baffles me that people were
able to ship code! Downright shocking and impressive in it's own way.
We struggled along until we hit the next major problem: the actual god
damn act of programming the fucking thing.

At the time of this writing there are multiple build tools. You may
know Yeoman, Brunch, or even Iridium. There was a time before these
things and it fucking sucked. Take a step back and thing of all the
things you need to develop a decent app at scale:

1. CSS reprocessing. If you aren't using SOMETHING then you're really
   doing yourself a diservice.
2. CoffeeScript. I think CoffeeScript is so much nicer than plain
   Javascript so I vote it's required. This is my blog, I do what I
   want.
3. Module wrapping. You need something to wrap individual source files
   into modules so they can be required.
4. Template handling. Read handlebars.
5. Template precopilation. Ain't no body got time to compile templates
   in production.
6. Asset concatenation. No one is going to make 500 network requests
   to load all your javascript classes.
7. Asset minification. Duh.
8. Different environment support. Things behave differently when
   you're developing, testing, and in production. This is a fact of
   life.
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
I did what any self respecting pioneer would do. I built that shit. 
[Frontend Server](/asf) was announced on 2012-02-20. This was just 
enough get our team off the ground. It didn't do all the things we
needed but it gave us a simple way to develop and deploy to staging.

Ember development continued and more or less stayed the same. Things
more or less worked but there was a lot to be desired. In this time we
hired more people and continued to build the product. We hit the
second build tool wall. We needed something better than frontend
server and hit other major issues. This shit was entirely difficult to
test and we had no test framework. So with those things in mind, I set
out to actually solve the build tool / development tool chain problem
once and for all. [Iridium](http://github.com/radiumsoftware/iridium)
came out of it all. 

Iridium is without a doubt my favorite bit of code I've ever written.
We have been using Iridium for almost a year now. I took a long time
for the project to settle, but now it's stable as rock. I can say
without a doubt that we could not build our product without it. It has
nothing to do with Ember at all. This is the simple fact of what it
takes to develop applications from the browser. I took to road to try
to share with people what was happening in this space. I blogged about
it, spoke about it at user groups all over europe, and conferences.
Just trying to get the message out. Speaking at Helsinki JS & Paris
Ember were my iridium favorites. I spoke at Reject.js in Berlin about
testing. That was awesome as well. I simply wanted people to know what
it was like to be in the position--that it's really not so great but
there are people pushing the boundaries. We are pioneers after all.

We've been in heads down ember development for the past 7-8 months or
so. We fought with testing. [Paul Cowan](http://twitter.com/dagda1)
and I were able to setup full integration tests. This was quite the
feat for us. We were able to simulate a user sitting and using the
application. All it took was an iframe and an absoluste pile of hacks.
We pushed very hard for a "reset" method. There were I think 3 or 4
people active in this area. There was us, [Paul Chavard](/), [Jo
Liss](/) and [Erik Bryn](http://twitter.com/ebryn). We shared our
implemenation and I think some of our ideas made it into the current
ember-testing package. Now it's atleast possible to test ember apps
out of the box without having to know every single bit of the
framework. Unfortunately we gave up on testing our application. Our
requirements were changing to fast and invalidating tests that were
taking too long to write. This was in December. Ember-Testing was
released in one of the RCs. The damn tests even ran on phantom for CI.
It was a miracle. I hope people out there are using ember-testing and
benefiting from all of our hard work in this area. We are pioneers
after all.

My team and myself have been using Ember since the dawn of time. We've
somehow managed to survive all the various versions. There was version
"0.9.8". It sounds so tantalizing close to 1. So tantalizingly close
to being done. But that is simply not the case. It was so far off on
it's value proces. Then there was Ember-Data. If you thought Ember was
bad for breaking changes and upgrading, then you haven't seen shit.
Try going from ED revision 4 to revision 10. There was simply no fucks
given about ED. Ember has been developing quite rapidly and the
concepts were clear. Ember Data was like code on a desinger's
sketchpad. Things would get erased and moved around without an after
thought. Such is life. We were figuring out what needed to be.  Then
came the pre releases. Now the RC's are coming. We're on RC5 right
now. I think we'll probably see RC9 or RC10 before serious
considerations are made of 1.0. I find this funny in a way. Do we
really need 6 or more RCs + prereleases? Perhaps we should have held
off for a while.

I'm sitting here looking back on where we came from and where we're
going. 1.0 is coming up. It will come eventually. Unfortunately it's
lacking some things. I find the lack of radio buttons to be undeniable
hillarious. It's just embarassing. Ember is "a framework for ambitious
web applications" as long as the ambitions don't include using radio
buttons. I'm going to dedicate some time to making sure this doesn't
happen. This week [Alex Matchneer](/)'s async router PR was merged.
This was most critical merge I think we've had in a long time. The new
router has been undergoing changes ever since it was merged. I think
it's still taking a long time to reach feature parity with the old
router. At least now we can finally build fucking authenticated
apps--because that is technology from the future.

I guess the question is "What does 1.0 mean?" I don't know anymore.
The version numbers mean nothing to me because we use master ember and
master ember-data. I just recorded an episode of the [Ember
Hotseat](http://emberhotseat.com). I mentioned that Ember was somewhat
of a shining city on a hill. It was a bastion of hope. Ember was going
to revolutionize client side development in the way Rails did
thousands of PHP developers. I think 1.0 is our first real stab at
building our city. Rome wasn't built in a day people. Rome sure as
fuck wasn't built in 2 or 3 years either.

There are lot of poeple migrating from backend to frontend. I was
lookign for a silver bullet. This was a major fail on my part.
Hindsight is always 20/20. I know other also think the same thing.
They think, I'll just switch to X and boom. Everything is fixed. [Trek
Glowacki] and I were having a conversation about the entire Ember and
JS ecosystem. He described the situation so perfectly. **Ember is like
Rails. Rails 0.51**. Let that sink in for a minute. How many of you
were around Rails in the early days? Shit was hard. How many years has
it taken Rails to become what it is now. Rails is rock solid. I want
that for Ember **badly**. I want that ecosystem. I want the framework
to enjoy those levels of success. I want people to enjoy building
browser apps.

The fact of the matter is that I don't enjoy building these
applications and time. It's fucking god damn difficult. It's not
entirely because of Ember. Ember works fucking amazingly at it's
core--and it will only get better. But it's things like CSS. Just
making columns in CSS is difficult. Let me rewind, I can't stand CSS.
I wish CSS was better because it's the most important aspect of the
web. It's unfortunate but end users really only care about what they
see. CSS is what they see. All of our hard work on computed
properties, sorting, and whatever architecture means nothing compared
to how the fucking application looks. Such is life. Then there is
Javascript itself. I'm not talking about Node. I'm talking about
browser javascript. Can a man get a package manager for fuck's sake?
Browser javascript leaves so much to be desired. This is why we have
things like Bower and other build tools--simply because we need to
manage the JS and compile/concatenate it ourselves. I don't like this
world. I hope to god it changes.

Ember's community is small but **intensily** passionate. I haven't
seen this much dedication in a group of poeple before. I think that's
because are all pioneers. We are all working together to do something
that hasn't been done before. We are leveling up the web platform. I
have this picture in my head. The Ember core team and other key
contributors have just landed in motherfucking Jamestown, Virginia.
We've been actively colonizing our small city building up on core
concepts. We've been making everything we need to simply survive in
this new world. We can handle URL's, update views, and manage data in
remote sources. This is enough to build a foundation. More and more
people are coming into Jamestown from other major places like .NET and
Java. We're in this melting pot making it all work. Yehuda has left
the colony for the true wilderness: TC9 and future versions of
Javscript. He's like Lewis and Clark. He's working on Web Components
and other things that simply so far out in the future. Hopefully
he'll come back after his journey bearing a ton of knowledge and use
tools for us back in the colony to use. In the mean time, we will be
here working--building up our Rome. Some of us actively working on
Ember-Data (which I believe is single most important part of the whole
thing since applications are nothing without data). Others will work
on animations, validations, package managers, plugin ecosystems, and
god knows what else.

There are a few things that scare me and excite me about this analogy.
We all knew what America has become but it sure took a shit load to
get there. How many people died during colonization? (Read get burned
out, exhausted, or simply collapse under the difficult). Then there
was the civil war and a host of other conflicts (Read internal
disagreement about what to do / where we're going). Then I think to
myself look America became. There were people who believed in a vision
of a new world and who had the pioneering build it. We have years to
go as a community to get to that shinity city on a hill status.
I think America became so much more than the initial settlers thought
it could be. This excites me. Perhaps we can change the web beyond our
wildest dreams. After all, we are pioneers and can make it happen.

I'd like to take a moment to call out some fellow pionners for their
hard work and dedication to the cause: Yehuda Katz, Tom Dale, Erik
Bryn, Paul Chavard, Stefen Penner, Kris Selden, Luke Melia, Peter
Wagenet, Kasper Tidleman, Jakub Arnold, Trek Glowacki, Joachim Haagen
Skeie, Igor Tezic, Robin Ward, Sami Asikainen, Jeff Atwood, Alex
Matchneer, Paul Cowan, Joshua Jones, Piotr Sarnacki, Gordon Hempton,
Dudley Flanders, Devin Torres, Ryan Florence, Andy Leeper, Brian
Cardella, and everyone else who has submitted a PR to Ember or Ember
Data. All of these people have contributed something and their efforts
do not go unnoticed or unappreciated.
