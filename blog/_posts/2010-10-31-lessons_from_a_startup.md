---
layout: post
title: Lessons From a Startup
---

I’ve been working as the lead developer at Finnish start up for about 9 months now.
We’re making a cool product that we’ve got high hopes for. We’re getting our 
first customers now, so I’m taking some time to reflect on our progress and what I’ve learned.

## 1. Don't Release Unfinished Code
This seems like a no brainer, but sometimes the excitement about a new feature gets 
the best of you and you push it out before you’ve had adequate time to to test it. 
I’m not talking about just integration testing, but letting some test users play 
with and make sure it’s working to their requirements and not yours. Last month 
we had a major feature released, it had already been delayed due to bug fixes. 
We held off and kept working on it. When we did release the feature it turned 
out that it still wasn’t done and we had to go shock and awe on the bug list.
It’s better to be late and correct, then early and look like a noob. We learned that lesson.

## 2. Don't Trust Third Parties
Our product integrates pretty heavily with various third party products. 
At one point we were working with four third parties to provide crucial 
parts of our product. Their services seemed useful, but we ran into problems
when it came into crunch time. Our problem was that our release dates where 
not inline with their time. For example, we were waiting a month for one 
company to provide some information/API stuff for us. We wanted to roll
out the feature in two weeks, but as time went on, we had to cut the feature
because the third party couldn’t deliver. We are starting another third party
integration. In the planning phase, we just assumed it would take twice or 
even three times as long as they say–this is simply because they’ve got their own business too.

## 3. Have (small) Goals
We are big dreamers. We want our product to be the shit. We want it to be awesome. 
We want to be a swiss army knife made out of unicorns tears flying 
around with a gold cape. We also need to sell this thing and develop real features. 
It’s been easy for us to get distracted and not focus on getting useful things done. 
What we need to do is focus on small features and deliverables. There are quick wins
and small steps. Remember to set goals you can make–and be realistic about them! 
You only hurt yourself by setting unrealastic goals for yourself. Know your limits
and work within in them. We learned this lesson as well.

## 4. Have a Vision
The vision is the over arching goal and purpose of what you’re doing.
Someone needs to have this, or you’re just a leaf in the wind. However, don’t get
your vision confused with your goals! You set goals in order to meet the vision. 
Your goals build up to a product that fulfills the vision. Also, be realistic 
about your vision. If you’re not making any cash, then your vision must be to 
make some money and set goals to make that happen.

## 5. Have a Standard
We’ve had a few developers come and go through the course of the project.
I’ve been the only constant. In the beginning, it was wild west. Anyone could 
commit and features were happening all over the place. We recently had someone 
new coming a few months ago to do front end work. The front end work is slowly 
transitioning into backend-ish work. That’s all good if you have people that 
can wear multiple hats, except there has to be rules. After a while I got fed up 
and wrote up a standards document. It laid out what would have to be in place for
ommits/features to be accepted and what kind of workflow to use. It’s published 
in the repo’s readme. All current and future developers will be held to the
standards laid out. Having standards should increase code quality over the project’s lifetime.

## 6. Invest in Testing
Test. Test. Test. Test. I love testing and you should to. Testing can save your life. 
Include time for testing in the release schedule. Include time for testing before
production deploys. Invest developer time in creating a good test suite. Use tools 
like specjour to distribute your test suite. Our cucumber test suite took ~1hr. 
Spent some time setting up specjour, got that sucker down to ~10min.
You’re integration suite should run quickly and you should run it often. 
If the suite takes too long to run, it will not run that often and you lose
the benefits of automated testing. Invest time and keeping this process lean. It will pay you back.

## 7. Make Software that Customers Want (and will pay for)
Duh. But, sometimes it’s easy to get distracted with stuff you think is cool.
Example: you think feature A is off-chain and it should totally be in the project. 
Customers are lined up waiting for feature B. Feature B isn’t as cool but is going to
bring in some cash. Work on feature B. Make a product that will sell and bring in money.
Our product is a game changer (I know you hear this every time you read about start ups).
When customers see what we’ve got cooking they are completely befuddled, next awe struck, 
then really interested. The project leader and myself are way past that phase.
We are no longer awe struck by what our product can do–but the customers still are! 
You should focus on developing features that customers want and not (all the time)
developing feature for yourself.

## 8. Know You're Gonna Make Mistakes
It goes without saying, but understand that you’re gonna mess up.
When you’re working in a startup, the business plan and overall
product is not set in stone. Remember to keep this mind and adapt to change.
