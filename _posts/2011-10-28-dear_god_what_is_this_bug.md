---
layout: post
title: Dear God?! What is this Bug?
tags: [rails]
---

A few days ago I had to do a very trivial task. One of my coworkers has
translated our Rails app into finnish. He sent me the `fi.yml` file for
me to add the application. I thought this process would take maybe ~30
mins. Turns out it took me **5 hours**. I'll tell you why.

## It All Started on Windows

I sent my coworker the existing yml file. I told him to replace the text
with the finnish version. He had a hard time just working with the yml
file so he made an excel spreadsheet so he could see the existing
english text in context. Then he put the finnish version next to it.
When he was done he wrote a script to take the finnish columns and
create the yml file. Sounds reasonable. I knew there would be formatting
mistakes related to tabs, spaces, :'s etc. So I figured I'd just have to
clean up the file before adding it to the locales. After a few days he
sent me the file. Then after a few weeks I had time to put it in--so I
downloaded `fi.yml` from gmail and off I went.

Drop the file in `config/locales` and start the server. BOOM. Syntax
error. Line #4. Ok, np, open up the file, figure there would be a
missing : or something. Nothing jumps out. Stare at it for about 30
minutes. Hmmm...there's _got_ to be something going on here. Open the
file up in textmate so I can see "invisibles." Nothing seems out of
place. I convert all tabs to spaces (I know YML parsers are bitchy when
it comes to this). Run the server again. Syntax error line #4. Le fu. At
this point I have no clue what it could be. I save the file in UTF8
(just to be sure) and convert all line breaks to unix format. Sill no
luck. At this point I'm out of ideas. So I just deleted the first block
of text and retyped it. Syntax error line 79! **HUZZAH!** Progress. Head
over to line 79. There are odvious issues which I take care off. All in
all it took little over an hour to clean up the 1,000+ line yml file.

## The Server Starts Finally

Now I'm ready to see the wondeful finnish version of the
application. I open up the settings page and switch the locale to
Suomen. Refresh the page and voilla! It's in English. Hmmm, this is
prolly just a dumb thing I did like forgetting the `before_filter` to
set the locale or forgetting to save the form. Ya know, something
**simple**. Do the quick status check. Everything is in proper order. My
locale is set to `fi` in the DB. The `before_filter :set_locale` is
being hit. Everything on my end seems to be as it should be. Now I have
to do the fun stuff which happens way to often on this project: debug
framework code. It's time to take a dive into `I18n.translate` which of
_course_ is modified by Rails for trickery.

## Into the Rabbit Hole

At this point, I just want to find out if the right locale and key is
being passed into I18n. After another bit of reading code (and learning
about I18n fallbacks) and I see that `:fi` is being passed into the
various translate functions. So at this point, I know these things.

1. My code to manage the locale is correct
2. My locale is set to :fi
3. The :fi locale is correctly being passed into I18n.

Now that I know this, I'm able to try to figure out why **every single
key** is falling back to english. After some more code reading I look
squarely at this method: (source taken from I18n code)

    def lookup(locale, key, scope = [], options = {})
      init_translations unless initialized?
      keys = I18n.normalize_keys(locale, key, scope, options[:separator])

      keys.inject(translations) do |result, _key|
        _key = _key.to_sym
        return nil unless result.is_a?(Hash) && result.has_key?(_key)
        result = result[_key]
        result = resolve(locale, _key, result, options.merge(:scope => nil)) if result.is_a?(Symbol)
        result
      end
    end

The underlying code is pretty simple. It loops over the translation keys
like: `[en, dashboard, subkey, key, key]` to find the actual value in
the translations hash. Ok, seems easy enough (recurring theme over the
course of this task), throw a debugger in and see what's happening.

So I put a debugger here:

    def lookup(locale, key, scope = [], options = {})
      init_translations unless initialized?
      keys = I18n.normalize_keys(locale, key, scope, options[:separator])

      keys.inject(translations) do |result, _key|
        _key = _key.to_sym
        debugger # <---------- Debugger added
        return nil unless result.is_a?(Hash) && result.has_key?(_key)
        result = result[_key]
        result = resolve(locale, _key, result, options.merge(:scope => nil)) if result.is_a?(Symbol)
        result
      end
    end

So I restart the server and go to page. My perfectly placed debugger
hits and I get the nice rdb prompt. This is where my brain **starts to
question everything it knows about Ruby**.

## 1 + 1 = 1

Now that I'm in my debugger I can see that `locale == :fi => true`. I
want to know why the key `fi.navigation.dashboard` is returning english.
So I **step.** and the method exists. Hmm. Apparently the translations
hash does not have the `:fi` key. What follows is something straight out
of the X-Files.

I quit the process and start over again. This time I don't step but
inspect what's going on in memory. Here's me in the debugger

    (rdb:2) translations.keys
    [:"en-us", :"de-ch", :en, :fi :"en-gb"]
    (rdb:2) translations[:fi]
    nil
    (rdb:2) translations[:en]
    {:invitation_mailer=>{:rejection_notification=>{:description=>"%{name} has rejected your invitation! You can reply to this email if\nyou'd like to contact them. They can still confirm later if they want.\nThey will still rece ... you the the point }
    (rdb:2)

Well this is looking **very** suspect. I'm thinking symbols are globally
unique! A `:fi` anywhere in any ruby source file in the same process is
equal to any other `:fi` in the same process. How can this possibly be!
Well, perhaps `translations` isn't a simple `Hash` but something like
`HashWithIndifferentAccess` or other trickery. A check to
`translations.class` returns `Hash`. At this point I'm absolutely
fucking confused because `translations[:fi]` is `nil` but
`translations[:en]` is correct. **AND** `translations.keys` has `:fi` in
the damn thing. So I start running around the room bouncing off walls
and other thing that don't make any sense because for some reason all I
know about Ruby symbols is wrong and that's causing my brain to
meltdown.

I start playing in the debugger more.

    (rdb:2) translations[translations.keys.first]
    # a ton of finnish
    (rdb:2) translations.keys[:fi]
    nil # wait wut.

Does. Not. Compute. Brain shutting down. More debugging:

    (rdb:2) translations.keys
    [:fi, :"en-gb", :en, :"en-us", :"de-ch"]
    (rdb:2) translations.keys.first == :fi # HMMMM. Highly suspect <------------ WTF!
    false
    (rdb:2) translations.keys.first
    :fi
    (rdb:2) translations.keys[2] == :en
    true
    (rdb:2) translations[:en]
    # a ton of english
    (rdb:2) translations[:fi]
    # nil
    (rdb:2) translations[translations.keys.first]

GAH. I cannot handle this. There has got to be some completly sinister
going on here. Something I've never heard about. Something that only
exists in comp.lang.c. Something that is out side of releam. Something
going in the C implementation. Just something fucking crazy.

This sort of bug induced comma has been going on for a few hours now.
Nearing the end of my rope I try some more things in the debugger:

    /Users/adam/.rvm/gems/ree-1.8.7-2011.03/gems/i18n-0.6.0/lib/i18n/backend/simple.rb:33
    locale = locale.to_sym
    (rdb:1) locale
    "fi"
    (rdb:1) locale == "fi"
    false
    (rdb:1) locale <=> "fi"
    1
    (rdb:1) locale.length
    5
    (rdb:1) "fi".length
    2

**HOLY CHRISTMAS**. There is the sinister bit! The keys are actually
different! This is completely masked by any call to `puts` or `to_sym`.
Now I have to figure out why in god's name is the key for finnish in the
`translations` 5 characters. There is only one other place that can
cause this problem: Where the YML files are parsed and put into the
translations file. I track that down and enter the debugger:

    (rdb:1) locale.bytes
    #<Enumerable::Enumerator:0x10ba360b8>
    (rdb:1) locale.bytes.map(&:to_s)
    ["239", "187", "191", "102", "105"]
    (rdb:1) "fi".bytes.map(&:to_s)
    ["102", "105"]

## Encodings, You've Done it to me Again!

Astute readers will notice that is there is a BOM in the key that's used
in the `translations` hash! So when I pass the string "fi" into
`I18n.translate` of course it doesn't have the BOM in it which
essentially equates to I18n thining that there is no such thing as that
locale. There are more sinister things at play here. I18n will call
`to_sym` for all keys that are entered into the translations hash.
_However_, ruby will not remove the BOM from the string when `to_sym` is
called. When you inspect that symbol in the debugger it will show as
`:fi`. When you call `locale.to_s` it will show `"fi"` so everything
_seems_ right on the surface. Underneath the covers it is horribly
wrong. Now I have to figure out if the problem is with my files or somee
other piece of code. Let's get a hex dump and figure out for sure.

Here is the hex dump of the `en.yml` file. 

    cs181226081:crm adam$ od config/locales/en.yml 
    0000000    067145  005072  020040  067554  060543  062554  035163  020012

Now we have the eternally lovely `fi.yml`

    cs181226081:crm adam$ od -ax config/locales/fi.yml 
    0000000    ?   ?   ?   f   i   :  nl  sp  sp   l   o   c   a   l   e   s
             bbef    66bf    3a69    200a    6c20    636f    6c61    7365

**Dear god**. There is a BOM at the start of the file. That was it?! Yes
folks, that was the problem. There was a BOM at the start of my locale
file. YAML (however it's coded) consumes the bytes and turns them to a
key for hash. Question: how come BOM are used to create keys to this
hash? Answer: Because I'm using Ruby 1.8.7 and everything's wrong!

People bitch about the YML parser on 1.9. I welcome it's strictness. I
don't think this would've happend on 1.9. There was some interesting
twist of fate in how Ruby 1.8.7 handles BOM's, encodings, and YAML. I
don't remember exactly what it was but I know this: It was the perfect
storm of everything going the exactly wrong direction to create the most
annoying bug I've ever seen. I like to describe these sitations with
this phrase: "a long and constant stream of unfortunate mistakes."

## Squashing the Bug

I don't hold anything aganist anyone. This is most likely some odd edge
case. I attribute this to the file coming from Windows, generated then
edited in god knows what way. I attribute it to encoding conversions.
There are a lot of possible ways this situation could happen. One thing
is for sure: any YML library on any version of Ruby should **not** allow
BOM markers in keys! This is crazy! I cannot think of any use case for
this behavior. 

After I finally got my head around what exactly what had happened I
could move forward. I copied the text to the clipboard and deleted the
existing file. I made a new file in the ever trustworthy VIM and pasted
it in. `:w`, then `./script/server`, and a refresh later: I see my
application in Finnish. Jesus christ. That took my a little over 5
hours. By this time I was completely mentally spent. A few fixes and
commits later I deployed a finnish version of the application--then I
didn't work on Rails for the rest of the day.

## Moral of the story

1. Use Ruby 1.9
2. Don't trust files from Windows
3. Turn invisibles on in your editor when editing YML files
4. Be sure to remove the BOM
5. Upgrade from Ruby 1.8.7

P.S. Here are the gists if you want to relive the horror.

[Debugging Session](https://gist.github.com/1319411)
[Hex Dumps](https://gist.github.com/1319579)
