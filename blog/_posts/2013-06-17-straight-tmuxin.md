---
title: Straight Tmuxin' Homie & Leaving Google
layout: post
---

This is a break from the usual format. I'm going to talk about my
tools and various other nerd config related things. This is because I
love to see other people's setups.
[r/battlestations](http://reddit.com/r/battlestations) is like porn to
me. I don't have a cool desk. I just have some cheap thing from ikea
with a cheap chair from ikea as well. Livin' the dream right? Instead
I have a balling terminal.

Personally I was using MacVim + Terminal.app. I was using TextMate for
a long time so MacVim was the perfect transition to a much more
powerful editor. Recently that setup has broke down. It wasn't
uncommon for me to have four or five terminal windows open with
accompanying MacVim windows. This becomes very awkward to manage. My
common workflow was to edit files in MacVim, then command tab (once)
back to Terminal.app, and run a command (usually tests). This worked
perfectly when I had one terminal and one editor. It falls on it's
face when there are multiple.

It was time to change my tools. I read Brian Hogan's book on tmux a
while ago. I set it up on my computer and tried it out or a few days.
I couldn't get into it. It was too awkward to switch between panes and
scroll panes. I had to do a lot of scrolling to see assertion failures
from tests runs as well as log scrolling. This coupled with having
multiple splits in Vim just made it too hard to get going. It was time
to reinvestigate Tmux after watching my setup make me unproductive and
frustrated. I knew that Tmux would scale infinitely. I was also
spending a lot of time setting up terminals and editors. I would
command q everything at the end of the day--a digital clock out if you
will. Then build it up the next day. What a gigantic waste of my time.
So I diligently set out to do Tmux the right way.

I used the `tmux.conf` file from the book was some minor changes. I've
made one small change: `PREFIX \` is mapped to split vertical. I can't
be bothered to remember to hit "PREFIX SHIFT |". Too many keystroke. I
spent a fair amount of time making it look nice and pretty. This took
the longest time. At least tmux is now pretty looking independent of whatever
crap the terminal is using for colors. I've also created numerous
sessions for all the different projects I work on. They have their log
panes, console windows, editors, test panes, all that jazz. I'm
totally loving it. `tmux attach -t blog` is wonderful. I can simply hit
`command enter` and boom. My entire workspace is full screen. So
without further jibber jabber. Here is some nerd porn:

![Tmux + Vim](/images/tmuxin.png)

Here's the meta. All configurations available in my
[dotfiles](https://github.com/ahawkins/dotfiles).

* Terminal: Iterm2
* Colors: My own custom (see my dotfiles repo)
* Tmux Styling: My own custom (see my dotfiles)
* Vim theme: Vividchalk by the vim god tpope.
* Music: The one and only: John 00 Flemin hailing from Brighton in the
  UK. That's just some candy from the tmux status menu.

I must say. I'm completely in love with this setup. It's so much
better than using MacVim. The colors aren't perfect (we only have 256
in the terminal) but it's made me more productive after one weekend
and it will scale infinitely.

## Leaving Google

This is just one small change in my overall setup. I've been using
Android since 2008 (wow!). I managed to lose my phone in Melbourne
after a night out with [@aptonik](http://twitter.com/aptonik). I
haven't had a smart phone since February. It's now the middle of
June. Over the course of those 4 months or so, google has really
started to piss me off. The hangouts thing has really pissed me off.
Dropping Jabber/XMPP is entirely annoying. This annoys me on principle
because Hangouts doesn't even seem that good. I have no interest in
installing **another** god damn messaging app in my computer. They
really fucked up there. Also, without Android you have no benefits of
being a google user. I don't use facebook. I can't stand google plus.
I only use google plus for hangouts with clients and to talk to one
friend. That's it. Social networking is not useful for me. I've been
waiting with bated breath to see what happens with iOS7 because I was
planning to switch to an iPhone.

Android and iOS are extensions of the underlying platforms. I'm
getting no benefit from google's services without android. Gmail is
free but email is not so important to me. I don't use calendars and
whatever shit they have. Google music is a joke, books, and all that
other nonsense. I use a Mac. It will take an awful lot for me to give
up my MacBook Air. It's the best god damn computer I've ever owned.
When they make a retina one I will gladly pay whatever they want. I'm
already using Apple's products (except iTunes because it is without a
doubt the worst fucking music library management and playback
software). So I decided make a drastic change in my entire digital
life: I left google. 

I switched Chrome for safari. I dropped Adium for Messages (since more
and more people I know are using iOS and I will be soon as will). I
signed up for hosted.im on my own new domain as well. I dropped Gmail
for FastMail.fm and Mail.app. I'm very curious how this whole thing
will turn out. I'm curious how much benefit I'll get out of this
setup, but I think it's time for a change. I think I'll see a real
benefit when I actually get an iPhone. I'm looking around for a cheap
4s. I'll buy a 5s when it comes out. I'm especially waiting for
Mavericks with maps on the desktop. IDK why in the fuck that took so
long. People need maps. Just give us the application. I'm planning on
doing an update in a couple weeks. I'm hopeful. We'll see how it goes.
