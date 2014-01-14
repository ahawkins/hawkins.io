Applications are nothing without data. Use cases interact with and
expose business objects. The only way for delivery mechanism to access
domain objects is through use cases. The only way use cases access
business objects is through a repository. This is the single most
important boundary you can have. There **must** be a strong separation
between the data and storage. Removing it promises pain. Using a
repository has honestly made me a happier programmer. I'll sum up the
most important parts in no practicular order.

* Having a boundary between objects and persistance allows each side
  to vary independently.
* The storage mechanism can be switched out with confidence (read: use
  memory in tests instead of a slower persistance mechanism)
* Every single data access goes through a single interface. This is
  great for caching and other optimizations
* All queries are made through a standard interface and into the
  repository. It is **impossible** for implementation details to leak
  into other parts of the applications.
* Easy to persist different models in use case speficic data stores.
  Need a simple key-value store? Implement part of the repoistory
  adapter using Redis. Other parts can be files, RDMS's or even as
  Uncle Bob puts it: "battery packed remoted controlled writing
  machines."
* Specific queries can be implemented in faster ways. Part of radium
  stores object graphs in views for ulimate speed. This is implemented
  using a separate code path for single object type queries and graph
  type queries. The semantics are all encapsulated in a single class.
  No details leak out.

Avid mentioned the repistory and query patterns. He said he had not
seen a use for them. I figured I'd fast forward a little. I went from
using _only_ ActiveRecord (and thusly the pattern itself) to
repository + query. The results have been wonderful. I was concerned
it would feel awkward in a smaller application. I'm pleased to say
that it doesn't. I do everything this way these days. It makes things
much better. Now that the repository has been beaten to death, it's
time to move onto business objects!

Business objects are plain old ruby classes with a bunch of
`attr_accessors`. They usually include modules for shared
functionality (but not so much). They are boring classes in a way
because the usually don't have so much logic. They encapsulate
business rules for their given state and some other stuff. Most
include the `Peristance` module. It declares an `id` `attr_accessor`
and a `save` method. The save method delegates to the correct
repository. This way I don't have calls to `XXXRepo` all over the code
when I simply want to persist a given business object.

The classes themselves are not so interesting. It's more interesting
how they are constructed and organized. In the past the models have
always represented presistance. This meant the DB's abstractions and
limitations leaked all over application. Now I just toss the object to
the repository and that handles it. I'm free to organize and construct
the domain objects in a way that makes sense for the specific use
cases--not the storage requirements. This has been a joy.
Unfortunately I cannot exmaine some examples of this without a lot of
ceremony and context. So you'll have to try it yourself for a while
and see what you think.

All of this makes writing tests suites much easier and faster. They
are faster beacuse every external communication happens through a
defined interface and boundary. Each boundary is swapped with an in
memory style implementation. The tests are also much faster because I
stay very mindful of what dependencies I bring into the project. If a
gem has more than two (generally) dependencies it doesn't make the
cut. The liberal use of exceptions make debugging tests easier as
well. Sinatra works perfectly with `rack-test`. It's dead easy to test
business logic: instantiate the use case and call `run!`. Boundary
specific things (like persistance implementations) happen in their own
tests. Instantiate the implementation, call the method, and asser the
result. I feel most confident in my code because it's easier to test
and thusly there are more test cases. I do all development & testing
using in memory implementations to flesh out the concepts and
interactions. There is usually a "ci" style test which uses the real
implementations. Example: I usually run the tests against the in
memory adapter, but CI will use the actual PostgreSQL implementation.
This keeps my tests fast and gives me confidence in production
environments. I use minitest because it is the best. I used to use
RSpec but what's the point? It doesn't add anything significantly
useful. I do concede one point: the failure messages are easier to
understand in some scenarios. But I don't think it's worth it to bring
in another dependency for "nice to haves." MiniTest is pure ruby and
comes in the standard library. Win-Win. I also find myself mocking and
stubbing a lot less. I think this a big win because I don't end up
with tests that rely to much on whitebox implementations. I can simply
stick a different black box on the end and see what the other side
does. This gives me more confidence in the code.

```ruby
class Group
  include Persistance
  include Serialization
  include Chassis::HashInitializer

  attr_accessor :name, :admin, :users, :pictures
  attr_accessor :cover
  attr_accessor :created_at, :updated_at

  def initialize(*args, &block)
    super
    @pictures ||= []
  end

  def save
    self.created_at = Time.now.utc if new_record?
    self.updated_at = Time.now.utc
    super
  end

  def total_pictures
    pictures.size
  end

  def member?(user)
    users.include? user
  end
end
```

Here is the persistance module:

```ruby
module Persistance
  extend ActiveSupport::Concern

  included do
    attr_accessor :id
  end

  module ClassMethods
    def create(*args, &block)
      record = new(*args, &block)
      record.save
      record
    end

    def repo
      @repo ||= "#{name}Repo".constantize
    end
  end

  def save
    repo.save self
  end

  def destroy
    repo.delete self
  end

  def save!
    save
  end

  def new_record?
    id.nil?
  end

  def ==(o)
    if o.instance_of? self.class
      o && o.id == id
    else
      false
    end
  end

  def eql?(o)
    self == o
  end

  def hash
    id
  end

  def repo
    self.class.repo
  end

  def inspect
    "<#{self.class.name}:#{id}>"
  end
end
```

```ruby
class UserRepo
  extend Chassis::Repo::Delegation

  class UnknownTokenError < StandardError
    def initialize(token)
      @token = token
    end

    def to_s
      "Could not identifiy user with token: #{@token}"
    end
  end

  class UnknownPhoneNumber < StandardError
    def initialize(phone_number)
      @phone_number = phone_number
    end

    def to_s
      "Could not identifiy user with phone number: #{@phone_number}"
    end
  end

  class << self
    def find_by_token!(token)
      user = query UserWithToken.new(token)
      raise UnknownTokenError, token if user.nil?
      user
    end

    def find_by_phone_number!(phone_number)
      user = query UserWithPhoneNumber.new(phone_number)
      raise UnknownPhoneNumber, phone_number if user.nil?
      user
    end
  end
end

UserWithToken = Struct.new :token
UserWithPhoneNumber = Struct.new :phone_number
```

Finally my in memory adapter for testing.

```ruby
class InMemoryAdapter < Chassis::Repo::InMemoryAdapter
  def query_auth_token_with_code(klass, q)
    all(klass).find do |auth_token|
      auth_token.code == q.code
    end
  end

  def query_user_with_token(klass, q)
    all(klass).find do |user|
      user.token == q.token
    end
  end

  def query_user_with_phone_number(klass, q)
    all(klass).find do |user|
      user.phone_number == q.phone_number
    end
  end

  def query_groups_for_user(klass, q)
    set = all(klass).select do |group|
      group.users.include? q.user
    end

    if q.updated_after
      set.select! do |group|
        group.updated_at.utc >= q.updated_after.utc
      end
    end

    set
  end
end
```
