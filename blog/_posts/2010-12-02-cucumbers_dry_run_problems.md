---
layout: post
title: Cucumber's env.rb & Dry Run Problems
tags: [ruby, cucumber]
---

Env.rb setsup Cucumber's execution environment. The generated file from cucumber-rails essentially loads your rails env
and setups up Capybara etc. That's all well and good but what do you do if you need to add your own stuff. Once you've built up a sizeable cucumber test suite, it's probable that you've got some modifications to env.rb. However, they **should not** be there since when you upgrade to a new version of cucumber (mainly cucumber-rails) it wants to regenerate that file. So what you need to do is split up your modifications into sepearate files. Here are some modifications you may have:

1. Modifying your Capybara driver (yay chrome)
2. Loading blueprints
3. Customizing specjour
4. Settings other constants
5. Insert random code
  
That's all well and good but it's not the correct way to do it. There are few options. You can split each modification into its own file and drop it in /features/support. Cucumber will autoload **all** files in side this directory. Technically it matches all files using this glob pattern: `features/**/*.rb`. However env.rb is loaded **before** all other files in features/support. This means you can drop create a file like this for specjour into `features/support/specjour.rb`:

```ruby
# tell Capybara to start a server on any open port
# since specjour will start multiple workers on the same computer
# and hence Capybara will try to connect to the same port 
# locking up the test suite
if ENV['TEST_ENV_NUMBER']
  Capybara::Server.class_eval do
    def find_available_port
      server = TCPServer.new('127.0.0.1', 0)
      @port = server.addr[1]
    ensure
      server.close if server
    end
  end
end
```

That fill will be loaded **after** env.rb when you **execute** your tests. This does create an interesting wrinkle.
I use dry run mode a lot in my suite. I refactor my features and steps quite often as I get a better understanding of the domain.
I use dry run mode to check to see if all the steps are defined before executing the test suite. The test suite can take over an hour. :( Cucumber does not load env.rb in dry run mode, it **does** load all other files in /features/support. This creates a problem if you have files in features/support that require env.rb to be loaded. For instance the specjour example I posted requires the capybara gem to be loaded. You could add:

    require 'capybara'
    
But it won't be able to find the gem since the gem environment is not loaded when the file is required.
In dry run mode cucumber does not load files that match this regular expression: `support\/env\..*`. Interestingly Cucumber does not simply select features/support/env.rb 
since that is the standard file. That means you can name files "env.specjour.rb" or "env.capybara.rb" to have them execluded in dry run mode. Although, this issue is only present when you run features using the cucumber binary.
If you run features through rake then you will not have problems since the complete rails environment is loaded before
cucumber is loaded. 

tl;dr
PROTIP: put things you would've added to env.rb in a file in /features/support/customer\_modification\_.rb.
If you run those features with rake you'll be ok. If you run those features with the cucumber command you'll be ok.
If those modifications required env.rb to be loaded and you run features with cucumber in dry run mode name them: features/support/env.modification.rb.

