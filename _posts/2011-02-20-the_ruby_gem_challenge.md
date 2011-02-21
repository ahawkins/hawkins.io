---
layout: post
title: 'The Ruby Gem Challenge'
tags: [ruby, gems]
---

I am working on a gem ranking website. One of the metrics is test
results. Getting test result for a random project can be a very
difficult task. I've cloned 3,081 different gems onto my computer. I've
written a simple bash script to execute this loop:

    for repo in ~/repos/* ; do
      cd ${repo}
      rvm use 1.8.7@${repo}
      bundle
      rake
    done

Nothing fancy going on there. However, **the results are appalling.**
Very few gems work out of the box on a clean machine. I think this a
huge failure for gem developers. If you don't have a rake task that can
execute tests in a clean environment then you have a problem! I thought
to myself, surely this cannot be the case. I tested well known gems like
devise. No dice. I tested cancan. That didn't work as well. I tried to
test some of gem's I've used. Not much luck there. I have the script
running in a console right now. AASM just worked with 100% passing.
I've tweeted some gems that work as well. Mail and HTTParty worked out
of the box. HTTParty even had cucumber features passing! I think the gem
authors (myself included) should rise to the occasion and make it easier
for other people to test our gems! I think this would speak very highly
of the ruby community. Everyone should try the Ruby Gem challenge out on
their favorite gem:

1. Clone repo into fresh directory
2. Create empty gemset and bundle 
3. Bundle (If the gem does not use bunder, fail right there)
4. Execute `rake`
5. Report results

After running this test through many many gems, I have a new found
respect for the authors of the gems that passed my tests. Try it out and
let me and the authors know your results!

PS. It will also be nearly impossible to get above an 80% ranking on
whatgem when I implement this scheme. That will **really** sort out the
good from the bad.
