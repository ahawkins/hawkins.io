---
title: Using the Ruby Logger
layout: post
---

Ruby has a logging built in. Simply require `logger` and you're off to the
races. Don't waste your time with log4r or anything else. The standard logger
is good enough for almost every use case I've heard of. Less dependencies are
always important. Use the standard library when you can.

The interface is easy to use. You've probably seen this:

```ruby
logger = Logger.new File.new('test.log')
logger.debug "debugging info"
logger.info "general logs"
logger.warn "oh my…this isn't good"
logger.error "boom!"
logger.fatal "oh crap…"
```

Each method is tied to a specific log level. There are 6 levels:
`Logger::DEBUG`, `Logger::INFO`, `Logger::WARN`, `Logger::Error`,
`Logger::FATAL`, and `Logger::UNKOWN`. You can set the log level by writing
`logger.level = Logger::DEBUG`.

You can also provide a `progname`. This is inserted into each log entry. Have you
ever done anything like this? `logger.debug "[worker] doing something…"` or
`logger.info "[email] sending invitation"`. I think pretty much everyone has.
This is exactly what `progname` is for. Here's an example:

```ruby
logger.info 'worker' { 'doing hard work' }
```

The syntax is weird, but it gets the job done. The initial argument is the
name, and the block returns the message. You can also set the `progname`
attribute. This is perfect for when you have a logger for various subsystems.

```ruby
logger = Logger.new some_file

# all messages will include "sync"
logger.progname = 'sync'

logger.info 'doing some stuff'
logger.error 'boom!'
```

This is a much better solution. You can still change the `progname` with the
block form.

You can also change the formatter. This object that defines what a log
message looks like. It must respond to `call`. The signature looks like this:

```ruby
call(severity, time, progname, msg)
```

You can implement a simple formatter like this:

```ruby
logger.formatter = proc do |serverity, time, progname, msg|
  msg
end
```

You can also create a `Formatter` object if that's more your style. I recommend
this approach because you can subclass `Logger::Formatter` and get error
handling for free. What do I mean? Take a look at this common code:

```ruby
logger.error "Something blew up!"
logger.error "#{err.message}"
logger.error err.backtrace.join("\n")
```

3 lines to print some error information! The the default
formatter handles exceptions by default It will print the error and the
backtrace for you. Those lines can be reduced to:

```ruby
logger.error "Something blew up!"
logger.error ex
```

This also has annoyed me, but once I learned that it handled errors by default
I was able to clean up a lot of code. I recommend you go with something like
this:

```ruby
class CustomFormater < Logger::Formater
  def call(severity, time, progname, msg)
   # msg2str is the internal helper that handles different msgs correctly
    "#{time} - #{msg2str(msg)}"
  end
end
```

It is more verbose but you only see it once so it's not such a big deal.

## Tips & Tricks

Have you ever needed to test a logger or redirect it's output to something you
can interact with? Perhaps `StringIO` works for you. `Logger#initialize`
expects an `IO` objects. Anyone will do. Here's an example:

```ruby
require 'stringio'
require 'logger'
file = StringIO.new
logger = Logger.new file

# do logging stuff

# now get the log's contents
log = file.rewind.read
```

Voilla, no file dependencies!

Here's another scenario. Have you ever needed to simply tell a library to be
quiet? This is very common in tests. The best way is to substitute a null
object. Google the null object pattern if you're not familiar with this. This
is better than changing the log level or using a temp file, insert other
solution here. You can create a null logger by overriding two methods:

```ruby
class NullLoger < Logger
  def initialize(*args)
  end

  def add(*args, &block)
  end
end
```

`add` is the internal method all the other methods go through. `initialize` is
also overridden. This means you can pass whatever you want because it makes no
difference. You could chose to use the same method signature if you wanted, but
I don't think it really matters. Now the logger will do nothing and you don't
have see any output or worry about log files.

Here's the final tip. This is my preferred way to create loggers.

```
App.logger = Logger.new($stdout).tap do |log|
  log.progname = 'name-of-subsystem'
end
```

I always set `progname`. It makes it easier to track the logs. It's set in one place and everything uses it.

I've also released a gem called "better\_logger". It provides a few simple
usability enhancements to the stdlib logger. You can check it out on
[github](https://github.com/ahawkins/better_logger).

Happy logging!
