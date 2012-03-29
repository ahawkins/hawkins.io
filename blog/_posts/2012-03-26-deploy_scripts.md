---
layout: post
title: "Deploy Scripts for Git & Heroku Applications"
tags: [devops]
---

Our company is growing. It's not longer just me. I'm not the only one
who deploys code anymore. All of our code is deployed to Heroku. You'd
think this is a very simple thing to do: `git push heroku master`. It is
on the surface. But think about everything you do **before** you deploy?
Do you tag commits? Do you merge into a production branch? Do you record
the deployed commit? Do you test that things are green on your CI
machine? There are lot of things you may do before. I used to do all
these sort of these manually. But now that someone else needs to deploy
code, it's time to automate it.

I started out writing a Rake task. This became unweidly. I needed
something more general for CLI applications. I thought about writing the
scripts in bash, but I don't have enough experience to write good bash
scripts or structure them to allow them to go. I do have plenty of
experience with Ruby. I decided to write my deploy script using 
[Thor](https://github.com/wycats/thor). Thor includes many different
utilities for interacting with the shell. For me, it feels like bash on
steroids and in Ruby which is a win. I wanted to create a simple script
so that I (or anyone else) could run:

    $ ./script/deploy

That way there is no fancy invocations. It could easily be extended to:
`./script/deploy (production|staging)`. 

The basic structure is to:

1. Check all preconditions
2. If all prereqs are green, then continue
3. Compile assets
4. Record a deploy commit
5. Push to github
6. Push to heroku
7. Log all this stuff

Here are the prereqs:

1. There are no uncommited files
2. User can ssh to github
3. User can ssh to heroku
4. HEAD is fast forward commit to master
5. HEAD hasn't been deployed to heroku
6. All required ENV variables are present on Heroku
7. Assets compile correctly

And the deploy process

1. Compile assets
2. Record this commit and time in the deploy file
3. Push commit to github
4. Push commit to heroku

Now that the structure and understanding is there, here is the base
class for our deploy task.

    require "rubygems" # ruby1.9 doesn't "require" it though
    require "thor"

    RAILS_ROOT = File.expand_path "../../", __FILE__

    LOG_FILE = "#{RAILS_ROOT}/deploy.log"

    class Deploy < Thor
      include Thor::Actions

      class CommandFailed < StandardError ; end

      no_tasks do
        def run(command, options = {})
          `echo "#{command}" > #{LOG_FILE}`

          command = "#{command} > #{LOG_FILE} 2>&1" unless options[:capture]

          options[:verbose] ||= false

          super command, options
        end

        def run_with_status(command, options = {})
          run command, options
          $?
        end

        def success?(command, options = {})
          run_with_status(command, options).success?
        end

        def run!(command, options = {})
          raise CommandFailed, "Expected #{command} to return successfully, but didn't" unless success?(command, options)
        end

        def pass(message)
          say_status "OK", message, :green
          true
        end

        def abort_deploy(message)
          say_status "ABORT", message, :red
          say "Deploy Failed! Check log file #{LOG_FILE}"
        end

        def failure(message)
          say_status "FAIL", message, :red
          false
        end
      end
    end

I've added some helper methods to make it easier to write my scripts.
Mainly, to redefine `run` to return `$?` instead of whatever the script
output. I did this because I needed the exit code to check preconditions
and successful commands.  `run!` is important because it will raise an
error if a command fails. This is for the deploy stage when all commands
need to execute successfully for the deploy to succeed. The helpers
it easier to log the deploy process.

And now for the complete script:

    #!/usr/bin/env ruby
    require "rubygems" # ruby1.9 doesn't "require" it though
    require "thor"

    RAILS_ROOT = File.expand_path "../../", __FILE__

    LOG_FILE = "#{RAILS_ROOT}/deploy.log"

    class Deploy < Thor
      include Thor::Actions

      class CommandFailed < StandardError ; end

      no_tasks do
        def run(command, options = {})
          `echo "#{command}" > #{LOG_FILE}`

          command = "#{command} > #{LOG_FILE} 2>&1" unless options[:capture]

          options[:verbose] ||= false

          super command, options
        end

        def run_with_status(command, options = {})
          run command, options
          $?
        end

        def success?(command, options = {})
          run_with_status(command, options).success?
        end

        def run!(command, options = {})
          raise CommandFailed, "Expected #{command} to return successfully, but didn't" unless success?(command, options)
        end

        def pass(message)
          say_status "OK", message, :green
          true
        end

        def abort_deploy(message)
          say_status "ABORT", message, :red
          say "Deploy Failed! Check log file #{LOG_FILE}"
        end

        def failure(message)
          say_status "FAIL", message, :red
          false
        end
      end

      desc "ensure_environment", "Test Rails can boot"
      def ensure_environment
        inside RAILS_ROOT do
          if success? "RAILS_ENV=production bundle exec rake environment"
            return pass "Rails boots"
          else
            return failure "Make sure Rails can boot in Production locally"
          end
        end
      end

      desc "ensure_github_connection", "Tests this user can ssh to github"
      def ensure_github_connection
        if run_with_status("ssh -T git@github.com ").exitstatus == 1
          pass "Github conencted"
        else
          failure "SSH keys missing for Github"
        end
      end

      desc "ensure_heroku_connection", "Tests this user can access heroku"
      def ensure_heroku_connection
        if success? "heroku config"
          pass "Heroku connected"
        else
          failure "SSH key missing or user is not a collabator"
        end
      end

      desc "ensure_clean", "Test to see if the repo is clean"
      def ensure_clean
        if success? "git diff --exit-code"
          pass "No uncommited files"
        else
          failure "There are uncommited files"
        end
      end

      desc "ensure_heroku_outdated", "Test to see if this code has been deployed or not"
      def ensure_heroku_outdated
        if !success? "git diff head heroku/master --exit-code"
          pass "Code not deployed"
        else
          failure "Code already deployed"
        end
      end

      desc "ensure_fast_forward", "Tests if this is a fast forward commit"
      def ensure_head
        inside RAILS_ROOT do
          if success? "git pull origin master"
            return pass "Fast forwarded"
          else
            failure "Could not fast forward. Human required"
            run "git reset --hard HEAD"
            return false
          end
        end
      end

      desc "ensure_assets_compile", "Tests assets compile correctly"
      def ensure_assets_compile
        inside RAILS_ROOT do
          if success? "bundle exec rake assets:precompile"
            pass "Assts compiled"
            run "git reset --hard HEAD"
            return true
          else
            return failure "Assets failed to compiled"
          end
        end
      end

      desc "compile_assets", "Precompiles assets"
      def compile_assets
        inside RAILS_ROOT do
          run! "bundle exec rake assets:precompile"

          say_status "Assets", "Compiled"
        end
      end

      desc "record", "Records this deploy in deploys.md"
      def record
        inside RAILS_ROOT do
          commit_info = run('git show --format="format:%h - %an: %s"', :capture => true, :verbose => false).split("\n")[0]

          run "touch #{LOG_FILE}"

          format = "* [%s] %s\n"

          existing_contents = File.read "#{RAILS_ROOT}/deploys.md"

          File.open "#{RAILS_ROOT}/deploys.md", 'w' do |f|
            f.puts format % [Time.now.strftime("%Y-%m-%d %H:%M %z"), commit_info]
            f.puts existing_contents.chomp
          end

          say_status "Deploy Log", commit_info
        end

        true
      end

      desc "commit", "Commits assets and pushes to Github" 
      def commit
        inside RAILS_ROOT do
          run! "git add deploys.md"
          run! "git add public/assets"
          run! "git commit -m '[Deploy]'"
          @new_commit = true # so we can catch the failure and blow away the last commit
        end

        say_status "Deploy Files", "Commited"
      end

      desc "run_deploy", "Tests prereqs and runs a deploy"
      method_option :environment, :default => "production"
      def run_deploy
        say "Checking prereqs..."

        prereqs = invoke(:ensure_clean) &&
          invoke(:ensure_github_connection) &&
          invoke(:ensure_heroku_connection) &&
          invoke(:ensure_heroku_outdated) &&
          invoke(:ensure_head) &&
          invoke(:ensure_environment) &&
          invoke(:ensure_assets_compile)

        if !prereqs
          abort_deploy "Failed prereqs"
          return false
        end

        say "Running predeploy tasks..."

        begin
          invoke :compile_assets
          invoke :record
          invoke :commit
        rescue CommandFailed => ex
          abort_deploy "A deploy step failed to run: #{ex}"

          if @new_commit
            run "git reset HEAD~1"
          else
            run "git reset --hard HEAD"
          end

          return false
        end

        say "Deploying..."

        begin
          inside RAILS_ROOT do
            run! "git push origin master"
            say_status "Github", "Pushed"

            run! "git push heroku master"
            say_status "Heorku", "Deployed"
          end
        rescue CommandFailed => ex
          abort_deploy "Push failed. Please check logs."
        end
      end

      default_task :run_deploy
    end

    Deploy.start


Each step is wrapped in its own method. Thor makes each method
available. This way you can easily test the individual sections. The
deploy task checks all the prereqs, then does all the hard work. It also
looks pretty while doing it thanks to built in colorization support from
thor. Happy deploying!

**UPDATE**: Here is the link to simple expandable version in a [gist](https://gist.github.com/2237714)
