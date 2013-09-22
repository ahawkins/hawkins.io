---
title: Durable AMQP Applications
layout: post
---

We've started using RabbitMQ at my day job. The initial use case is to
stream create/update/delete events (like a firehose) to other parts in
the system. This is a mission critical queue--we can't afford to lose
messages. This post explains how to create RabbitMQ producers with
failure handling and durability in mind.

Let's start at the beginning. There is a connection to the server.
You open a channel between your application and the connection.
Exchanges communicate over the channel. Queues bind to exchanges.
Messages are sent over queues.

Exchanges & queues are ephemeral by default. They live and die with the
application the process. This means they will not survive application
or server restarts. You can declare them as durable. Durable items
live outside of processes and server. So if the process dies or the
server restarts things will be as they were. Durable queues and
exchanges are the first step to a robust application.

Messages may also be "durable". Publish messages with the
`:persistent` flag and RabbitMQ will write the message to disk.
The messages are loaded from disk when server restarts and sent to any
existing queues.

Durable queues/exchanges and persistent messages will get you pretty
far. They keep things working under normal conditions. There is
another problem: network issues. What happens when the connection is
lost? How does the application reconnect? What happens to messages?

Application crashes and network issues are common. The amqp gem
implements a robust recovery protocol. In fact, it can recover from
network issues automatically when configured. The amqp will reconnect
to the server, redeclare exchanges, and any queues automatically. There
is still one problem: messages produced during a connection outage are
lost.

Unfortunately the amqp gem cannot help here. You may think: I have
the `:persistent` option, my messages are safe. This is incorrect. The
messages are only persisted on the server when the server is
connected. We need to handle this ourselves. The application must
buffer its messages while the connection is down. Then empty the
buffer when reconnection happens. There is another caveat here: what
happens if the application crashes or exits before buffer is drained?
The buffer itself should be persistent. This way the undelivered
messages will survive application crashes, server crashes, connection
losses, and application/server crashes during a connection loss.

This may seem like overkill. I assure you it's not for mission
critical messages. This is responsible. The final setup looks like
this. When the application starts drain the persistent buffer. This
publishes messages from a previous connection outage and application
exit. Whenever your app publishes a message, if connected publish with
the `:persistent` flag. If not, add it to the persistent buffer. The
producer can continue to "publish" during a connection outage.
Configure channels to use auto recovery. This should cover all the
bases.

There is always a trade off. Durability makes speed suffer since
messages/queues/buffers are written to disk. However, if you're
running a mission critical queue this a trade off you have to make. If
you're just sending metrics or logs then it's not so important.

I recommend reading the [error handling](http://rubyamqp.info/articles/error_handling/)
guide for the amqp gem. It covers things in more detail.

Thanks to [Michael Klishin](https://twitter.com/michaelklishin/) for
reviewing an early draft of this post and all his hard work on the
[amqp](https://github.com/ruby-amqp/amqp) and
[bunny](https://github.com/ruby-amqp/bunny) gems.

Here is an example producer as described in this article. I recommend
you refactor the `Buffer` class to take a redis connection as an
argument. The `key` method should also be an argument. This makes the
class more reusable. The code is here as a proof of concept.

```ruby
require 'amqp'
require 'em-redis'
require 'multi_json'

class Buffer
  def initialize(connection, exchange)
    @connection, @exchange = connection, exchange
    @redis = EM::Protocols::Redis.connect
  end

  def publish(message, options = {})
    if connected?
      @exchange.publish message, options
    else
      @redis.rpush key, MultiJson.dump({message: message, options: options})
    end
  end

  def drain
    @redis.llen key do |size|
      @redis.lrange key, 0, size do |messages|
        messages.each do |msg|
          hash = MultiJson.load msg
          @exchange.publish hash.fetch('message'), hash.fetch('options')
        end
        @redis.del key
      end
    end
  end

  private
  def key
    'messages'
  end

  def connected?
    @connection.connected?
  end
end

AMQP.start do |connection|
  channel = AMQP::Channel.new connection
  channel.auto_recovery = true

  exchange = channel.direct 'buffer-test', durable: true

  buffer = RedisBuffer.new connection, exchange
  buffer.drain

  counter = 1

  EM.add_periodic_timer 1 do
    msg = "Message #{counter}"
    buffer.publish msg, persistent: true
    counter = counter + 1
  end

  show_stopper = proc do
    puts "Going down"
    connection.disconnect
    exit
  end

  connection.on_error do |ch, connection_close|
    raise connection_close.reply_text
  end

  connection.on_tcp_connection_loss do |conn, settings|
    conn.periodically_reconnect 2
  end

  connection.after_recovery do
    puts "Reconnected!"
    buffer.drain
  end

  trap 'INT', &show_stopper
  trap 'TERM', &show_stopper
end
```

Here is a durable consumer as well.

```ruby
require 'amqp'

AMQP.start do |connection|
  connection.on_error do |ch, connection_close|
    raise connection_close.reply_text
  end

  connection.on_tcp_connection_loss do |conn, settings|
    conn.periodcially_reconnect 2
  end

  connection.after_recovery do
    puts "Reconnected!"
  end

  channel = AMQP::Channel.new connection
  channel.auto_recovery = true

  exchange = channel.direct 'buffer-test', durable: true
  queue = channel.queue(durable: true).bind(exchange)

  queue.subscribe do |headers, msg|
    puts msg
  end

  show_stopper = proc do
    puts "Going down"
    connection.disconnect
    exit
  end

  trap 'INT', &show_stopper
  trap 'TERM', &show_stopper
end
```

Start both of processes and experiment with killing them and the
server at different times to see how things work.
