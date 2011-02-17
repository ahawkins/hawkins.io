---
layout: post
title: 'app/observers -- Where They Should Be'
tags: [ruby, rspec]
---

Afer you've been doing Rails for a while you become old and cranky about how you want things. I *love* my observers in /app/obsevers. I do not understand why they are not their by default. Models, mailers, and controllers all have their own folders, why can't observers by default. They don't even make any sense in /app/models. #1 They don't model anything and #2 They aren't subclasses of ActiveRecord (or some other ORM). If all the classes in /app/models are subclasses of AR, then what is an observer breaks the pattern. In Rails 2 if you want to specify another directory to load code from you have to specify add it to the `config.load_path` variable. This is not the case in Rails 3. If you simply want to shove your observers into /app/observers, jsut make the directory and move the files in there. You will have to move them if you don't patch the `rails g observer` command to generate them in a new directory. That takes care of Rails, but now that we have our observers separated, it's safe to assume we want to be able to run `rake spec:obsevers`. This is not a problem either. All you have to do is create a rake spec task to only run files in spec/observers. So drop this bad boy in /lib/tasks

    require 'rspec/core'
    require 'rspec/core/rake_task'
    Rake.application.instance_variable_get('@tasks')['default'].prerequisites.delete('test')

    spec_prereq = Rails.configuration.generators.options[:rails][:orm] == :active_record ?  "db:test:prepare" : :noop

    namespace :spec do
      [:observers].each do |sub|
        desc "Run the code examples in spec/#{sub}"
        RSpec::Core::RakeTask.new(sub => spec_prereq) do |t|
          t.pattern = "./spec/#{sub}/**/*_spec.rb"
        end
      end
    end

    
Now we have our own rake task for testing our observers. But let's take it one step further and make our observer specs a first class citizen in Rspec2. You know that when you write controller specs you can call the `controller` method or in helper specs there is a `helper` object that represents the object under test. This magic happens because rspec contains special code that runs when initial describe block matches something like xxxController or xxxHelper. If it matches, it loads some special code to make writing specs for these classes much easier. All you have to do is take a peek into the rspec-rails [source](http://github.com/rspec/rspec-rails/tree/master/lib/rspec/rails/example/) to see where the magic happens. I advice you to look at those files and figure out what's up. Creating a new observer example group is easy. Drop this bad boy in side /spec/support/observer\_example_group.rb

    module RSpec::Rails
      module ObserverExampleGroup    
        extend ActiveSupport::Concern
        extend RSpec::Rails::ModuleInclusion

        include RSpec::Rails::RailsExampleGroup

        def observer
          example.example_group.describes.instance
        end

        included do
          metadata[:type] = :observer
        end

        RSpec.configure &include_self_when_dir_matches('spec','observers')
      end
    end

    
This module adds some sugar to all specs in an observer example group. If your spec is in spec/observers you can now do something like this:


    describe AccountObserver do
      it "should send a welcome email" do
         AccountMailer.should_receive(:welcome_email).and_return(mock_mail)
         mock_mail.should_receive(:deliver)
         observer.after_create(mock_account) # notice observer is defined in the observer example group
      end
    end

    
Nice! We no longer have to call AccountObserver.instance in all our tests or set an @observer in a before filter. This also allows us to do some more cool stuff for our observer examples. You can include support modules for certian example by doing something like this in your spec_helper.rb file

    config.include ControllerHelpers, :type => :controller
  
Now we can do that for observers as well! You may by thinking where the hell did those mock_account and mock_email methods come from? You define then in an obesrver helper module inside the support directory then tell rspec to include them for all observers like so. First create this file: spec/support/observer_helpers.rb

    module ObserverHelpers
      def mock_account(stubs = {}) 
        @mock_account ||= mock_model(Account, stubs)
      end

      def mock_mail(stubs = {}) 
        @mock_mail ||= mock(Mail, stubs)
      end
    end

Now in your spec helper: 

    config.include ObserverHelpers, :type => :observer

Poof! All done. Now you can go on your way running rake spec:observers and treating your observer specs as first class citizens w/Rspec2. Happy testing.

