---
title: Implementing the Repository Pattern in Ruby
layout: post
---

The repository pattern is one of my favorite architectural design
patterns. The repository pattern simplifies domain object access,
querying, and creates a clear boundary between objects and their
persistence. Patterns of Enterprise Architecture sums it up nicely:

> Mediates between the domain and data mapping layers using a
> collection-like interface for accessing domain objects.

The repository pattern usually goes hand in hand with different
storage adapters (another design pattern). You should not implement the
repository without this in mind! You may have an in memory adapter for
tests and a RDMS adapter for production. This is a definite win!

There are a few reasons why you may want to implement this pattern.
The repository pattern is extremely useful when you have complex
storage requirements or complicated access rules. It's especially
useful in separating persistence and domain objects.

Now that we have a general overview of what the pattern is and when
to apply it, let's get to the code! There are three object roles: the
repository itself, criteria, and adapters. The repository
delegates most of the work to the adapter. The adapter receives
criteria and returns matching domain objects.

Let's start by defining a CRUD interface.

```
class Repo
  self.adapter
    @adapter
  end

  self.adapter=(adapter)
    @adapter = adapter
  end

  def self.find(klass, id)
    adapter.find klass, id
  end

  def self.all(klass)
    adapter.all klass
  end

  def self.create(model)
    adapter.create(model)
  end

  def self.update(model)
    adapter.update(model)
  end

  def self.delete(model)
    adapter.delete model
  end
end
```

Nothing fancy yet, just a bunch of delegation. You'd use it like:
`Repo.all(Customer)` or `Repo.find(Order, '32489723-832')`. Notice
repository can manage multiple domain object types. Each is a unique
criteria.

We can create a save combinator to make things a little easier.

```ruby
class Repo
  def self.save(model)
    if model.id
      update model
    else
      create model
    end
  end
end
```

Query support is next. The caller specifies a criteria and it's
sent it to the adapter for retrieval. `Struct` works perfectly. Start
by defining a query interface on `Repo`. The query object defines the
need information such as date ranges, maximum ages, and things like
that. The adapter uses the criteria's attributes to match the correct
objects.

```ruby
class Repo
  def self.query(klass, selector)
    backend.query(klass, selector)
  end
end
```

Nothing fancy there, just delegation. Now let's see it in action.

```ruby
FirstTimeCustomers = Struct.new
CustomersWithActivity = Struct.new :dates

Repo.query(Customer, FirstTimeCustoemrs.new)
Repo.query(Customer, CustomersWithActivity.new(this_week))
```

That's all there is to it for the primary interface. Now let's look at
a simple in memory adapter.

```ruby
class InMemoryBackend
  def initialize
    @counter = 0
    @map = {}
  end

  def create(record)
    @counter = @counter + 1
    record.id ||= @counter
    map_for(record)[record.id] = record
  end

  def update(record)
    map_for(record)[record.id] = record
  end

  def delete(record)
    map_for(record).delete record.id
  end

  def find(klass, id)
    map_for_class(klass).fetch id
  end

  def all(klass)
    map_for_class(klass).values
  end

  def query(klass, selector)
    send "query_#{selector.class.name.underscore}", selector
  end

  private
  def map_for_class(klass)
    @map[klass.to_s.to_sym] ||= {}
  end

  def map_for(record)
    map_for_class(record.class)
  end
end
```

All objects are stored inside a hash. CRUD operations happen by
looking up a key. The query method assumes that a method handle each
query. We'd implement the previous queries like this:

```ruby
class MyAdapter < InMemoryAdapter
  def query_customers_with_activity(q)
    all.select do |customer|
      customer.activity_during? q.dates
    end
  end
end
```

It's annoying to always write out `Repo.find(klass, id)`. There is a
solution that uses reflection. It's safe to say that
`CustomerRepo` works with `Customer` objects. An `OrderRepo` works
with `Order` objects and so on. We can create a module that delegates
to the repo with the correct arguments.

```ruby
module Repo::Delegation
  def save(record)
    Repo.save(record)
  end

  def all
    Repo.all object_class
  end

  def find(id)
    Repo.find object_class, id
  end

  def delete(record)
    Repo.delete record
  end

  def query(selector)
    Repo.query object_class, selector
  end

  private
  def object_class
    @object_class ||= self.to_s.match(/^(.+)Repo/)[1].constantize
  end
end
```

Now we create the repos we want:

```ruby
class CustomerRepo
  extend Repo::Delegation
end

class OrderRepo
  extend Repo::Delegation
end
```

Use them like so:

```
CustomerRepo.all
CustomerRepo.find 5
```

Now that classes encapsulate all data access, we can start to build a
rich API. This is where the pattern really starts to shine. Check this out.

```ruby
class CustomerRepo
  def self.active_during(dates)
    query CustomersActiveDuring.new(dates)
  end
end
```

This is awesome because we have a public interface exposes how the
objects are required, but not does not expose any semantics about how
that happens.

That's all for the repository pattern. I hope this wet your whistle
and got you thinking.

NOTE: my upcoming Chassis gem will feature a similar implementation!
