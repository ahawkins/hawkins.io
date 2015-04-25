require 'concord'
require 'rom'

ROM.setup :memory

# Do not expose 3rd part interfaces directly. Instead create your
# own interface. This DataStore class encapsulates all persistence
# things with ROM and provides a single unified CQRS style inteface
# to the wider application.
class DataStore

  # Aggregration info classes. This is populated by looking at multiple
  # relations or things that would be outside the normal "query
  # relation" interface.
  class BucketInfo < DelegateClass(Bucket)
    attr_reader :total, :most_common_type

    def initialize(bucket, total, most_common_type)
      super bucket
      @total = total
      @most_common_type = most_common_type
    end
  end

  class BucketSummary
    include Lift

    attr_accessor :bucket, :counts, :traces
  end

  TypeCount = Struct.new :type, :total

  class Accounts < ROM::Relation[:memory]
    # Nice, no metaprogramming required. This could automatically be
    # deteremined by the class name, but I prefer explicit over
    # implicit.
    register_as :accounts

    # Define each unique read operation with it's own method.
    # Restrict is provided by rom. All queries most return
    # an enumerable relation. So it's up to the caller decide if
    # one or many are needed. ROM includes useful one & one! helpers
    # depending on the context.
    def with_id(id)
      restrict do |data|
        data.fetch(:id) == id
      end
    end

    def with_email(email)
      restrict do |data|
        data.fetch(:email).downcase == email.downcase
      end
    end
  end

  class AccountMapper < ROM::Mapper
    # Map a specific relation.
    relation :accounts

    register_as :entity

    # Here is my domain object. This is a simple class with Anima
    # included. Immutable entities are the best.
    model Account

    # List all attributes managed by the mapper. All these must
    # be public. The mapper excepts the registered Model class to
    # accept Hash of all these keys. It's up the model class if it
    # to instantiate itself.
    attribute :email
    attribute :password
  end

  # Every command is its own class. The command defines the relation
  # it operates on, and its return value. Commands may also have
  # validators associated with them. I opted to keep valdiations
  # outside of the command layer.
  class CreateAccount < ROM::Commands::Create[:memory]
    register_as :create
    relation :accounts
    result :one

    # The memory-based classes do not do ID generation for you. So in
    # this case, just create a UUID and assign it as the id.
    def execute(data)
      super(data.merge({ id: SecureRandom.uuid }))
    end
  end

  class ClearAccounts < ROM::Commands::Delete[:memory]
    register_as :clear

    relation :accounts

    # Simply wipe out the existing in memory collection
    def call
      relation.clear
    end
  end

  class Traces < ROM::Relation[:memory]
    register_as :traces

    forward :take

    def in_bucket(id, limit: nil)
      if limit
        restrict({ bucket_id: id }).take limit
      else
        restrict(bucket_id: id)
      end
    end

    def count_bucket(id)
      in_bucket(id).count
    end

    # Simulate a metadata type query using basic enumerbale
    # operations. This where the low level interace comes in handy.
    # Usually the relation method should return an relation. Instead
    # it's possible to return exactly what objects are required.
    def most_common_type(id)
      traces = in_bucket(id).to_a

      if traces.any?
        types = traces.group_by { |d| d.fetch(:type) }.to_a
        types.sort do |t1, t2|
          t2[1].size <=> t1[1].size
        end.first[0]
      else
        nil
      end
    end

    # More "low level" aggregration type qurires.
    def count_types(bucket_id)
      traces = in_bucket(bucket_id).to_a

      types = traces.group_by { |d| d.fetch(:type) }.to_a

      types.map do |pair|
        TypeCount.new pair[0], pair[1].size
      end.sort do |t1, t2|
        t2.total <=> t1.total
      end
    end
  end

  class TraceMapper < ROM::Mapper
    relation :traces
    register_as :entity

    model TraceLog

    attribute :id
    attribute :bucket_id

    attribute :type
    attribute :message
    attribute :trace
    attribute :context
  end

  class CreateTrace < ROM::Commands::Create[:memory]
    register_as :create
    relation :traces
    result :one

    def execute(data)
      super(data.merge({ id: SecureRandom.uuid }))
    end
  end

  class ClearTraces < ROM::Commands::Delete[:memory]
    register_as :clear
    relation :traces

    def call
      relation.clear
    end
  end

  class Buckets < ROM::Relation[:memory]
    register_as :buckets

    def for_account(id)
      restrict account_id: id
    end

    def with_id(id)
      restrict id: id
    end
  end

  class BucketMapper < ROM::Mapper
    relation :buckets
    register_as :entity

    model Bucket

    attribute :id
    attribute :bucket_id

    attribute :type
    attribute :message
    attribute :trace
    attribute :context
  end

  class CreateBucket < ROM::Commands::Create[:memory]
    register_as :create
    relation :buckets
    result :one

    def execute(data)
      super(data.merge({ id: SecureRandom.uuid }))
    end
  end

  class ClearBuckets < ROM::Commands::Delete[:memory]
    register_as :clear
    relation :buckets

    def call
      relation.clear
    end
  end

  # Concord for simple ROM encapsulation. All functionality required
  # for the application is implemented in ROM terms. This also
  # coordinates multiple operations. Concord also ensures ROM is
  # private so no one can backdoor into this object.
  include Concord.new(:rom)

  # I normally have a setup method here to match setup in tests. This
  # method would normally be used to bootstrap the data store. Since
  # the class uses in memory arrays there is nothing to do.
  def setup

  end

  # Delete everything from everything. Single interface to manage all
  # different relations.
  def teardown
    command(:accounts).clear.call
    command(:buckets).clear.call
    command(:traces).clear.call
  end

  # Another example of where encapsulation shines through. ROM
  # coommands return Hashes. Application requires accounts. Right now
  # there does not seems to be a straight forward way to implement
  # this semantic. The following methods exiting for the same reason.
  def create_account(data)
    Account.new command(:accounts).create.call(data)
  end

  def add_trace(bucket_id, data)
    command(:traces).create.call data.merge({ bucket_id: bucket_id })
  end

  def account_with_email(email)
    relation(:accounts).with_email(email).as(:entity).one
  end

  def account(id)
    relation(:accounts).with_id(id).as(:entity).one!
  end

  def create_bucket(account_id, data)
    command(:buckets).create.call data.merge({ account_id: account_id })
  end

  # This method has two purposes. First use uses the general query
  # interface to load the appropriate entities matching the account
  # ID. Next it uses the low level relation interface to call the data
  # store specific implementation of the aggregration methods. This
  # method returns the application specific BucketInfo class
  # representing everything required to present the object in a GUI.
  def buckets(account_id)
    # Here is the high level interface
    relation(:buckets).for_account(account_id).as(:entity).to_a.map do |bucket|
      # Low level interface where the relation registry is uses
      # directly.
      trace_count = rom.relations.traces.count_bucket bucket.id
      most_common_type = rom.relations.traces.most_common_type bucket.id

      BucketInfo.new bucket, trace_count, most_common_type
    end
  end

  # Another aggregration type method. The BucketSummary contains
  # information about the specific entity and it's associated
  # entities.
  def summarize_bucket(bucket_id, limit: 20)
    bucket = relation(:buckets).with_id(bucket_id).as(:entity).one!

    BucketSummary.new do |summary|
      summary.bucket = bucket
      summary.traces = relation(:traces).in_bucket(bucket_id, limit: limit).as(:entity).to_a
      summary.counts = rom.relations.traces.count_types bucket
    end
  end

  private

  def command(*args)
    rom.command(*args)
  end

  def relation(*args)
    rom.relation(*args)
  end
end

# I'm trying this sort of thing out. It seems sort of single reference
# object is required. I'm not entirely sure about this, but it seems
# nicer than having calls to DataStore.new ROM.default_env. I prefer
# this constant approach because I can set this at process boot time
# and never worry about another object.
REPO = DataStore.new ROM.finalize.env
