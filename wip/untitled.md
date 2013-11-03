---
title: Untitled
layout: post
---

**Abstract**: This paper describes an application architecture that
maximizes long term maintainability and feature deliverability for a
certain class of applications. It covers effective use of boundaries,
application roles, and application of design patterns to create an
architecture that separates the core business logic from the delivery
mechanisms. Problems with current approaches are covered. It finishes
with a migration strategy for existing applications.

--------------------------------------------------------------------

## Effective Design & Technical Investment

Effective software design focuses on enforcing boundaries and applying
design patterns. Maintainable systems have boundaries in the right
places. Design patterns organize code in predictable and
understandable ways. Both strategies actively defend against technical
debt and encourage technical investment. It is common knowledge that
you must invest to achieve long term success. You must invest in an
application's architecture to maximize its long term success, feature
deliverability, and scalability. It is time to apply the same long
term financial planning to software applications.

Technical debt is the cost of previous technical decisions.
Engineering work can be done in a quick and dirty way; doing exactly
what is needed for today in a way that may not work in the future. It
is about making a choice: quick and messy, or slower and cleaner.
Every programmer has made to make this decision "oh, I'll just hack
this in” then written FIXME directly above it." Then probably thought
to themselves how to actually implement it correctly.  Applications
often collapse under their technical debt. Applications become
impossible to maintain. The only way to pay back the debt is to start
over.  This is an unfortunate situation but it is avoidable. This
situation happens when engineering teams (for whatever reason) decide
to accumulate more technical debt. The decision usually comes from
business requirements and short delivery dates. Teams must actively
decide to pay back their debt in terms of technical investments.
Projects incur most technical debt in the early stages.  This is the
most delicate time in an application's life time. Just like real life
childhood, the decisions (good, bad, awesome, horrible) made in the
formative years have a strong last impact. The signs of excellent
parenting live on people grow into well adjusted individuals. Horrible
or abusive parenting often leave scars for life which are difficult or
impossible to heal without serious effort. This paper is about making
technical investment from t0 to raise a happy, mature, and
maintainable program. Children need proper nourishment from the
beginning. Applications require proper separation of concerns,
boundaries, objects roles, and design patterns.

Architecting applications means construction boundaries, defining
interactions, decoupling, and arranging objects in an extendable way.
Applications are usually tightly coupled to their delivery mechanism.
This is a big pain and makes it hard to extend existing code bases.
Arranging objects is the most difficult part. Possible Sandi Metz
quote. This paper demonstrates an object arrangement that exemplifies
all the important characteristics of a maintainable and extendable
application. Creating good software requires heavy focus on its core
functionality. These things are use cases.

## Use Cases: Heart of the System

A use case describes something a system does. It is a unit of work. A
CRM (Customer Relationship Management) system has use cases like
“create contact”, “invoice customer”, or “contact customer.” A
classifieds site like Craigslist has uses cases such as “post ad” or
“contact seller.” Use cases are things users can do. They should be at
the system’s core. Use cases have alternate flows and are often
composed into more complex flows. A CRM may want to add a customer
than contact them. This is possible when implemented correctly and
down right painful when it is not. Use cases are usually not straight
forward.  They must interact with many other entities in the system.
They are conductors orchestrating the interaction between all the
other entities in the system. A use cases takes in some form of input
and takes appropriate action. The input is examined and some records
are created or modifies. Perhaps some external state is modified (like
talking to an external service). Eventually the user is presented with
some interface showing the result of this interaction. This is how
software fundamentally it works. It all starts with handling user
input. I think this paragraph needs to focus more on defining
“domain."

Handling user input is one of the most boring task’s for programmers.
It always seems like unimportant work. Input must always be checked,
sanitized, and validated. The same type of code has been written
millions of times across the globe. Eventually this part of the work
is done and we can get back to the real meat of the problem. Handling
user input is actually extremely important to an application’s long
term health. Proper input checking makes code more confident. Avdi
Grimm used this term in his book “Confident Ruby.”  Insert Avdi Quote
here. He describes unconfident code as between too focused on edge
cases and input handling and that happening in many parts of the code.
Confident code does not have this problem. It knows what it has and
what to do. Proper input sanitization makes this possible. User input
should be checked and sanitized before it enters the system then never
again. Classes further down the chain receive the required objects and
go about their business. Consider a terminal based application. The
use case requires a Customer instance. It is impossible to input the
machine’s customer representation. Instead the user inputs a name or
unique ID. The system uses this information to look up the existing
customer instance. The instance is then passed to the use case for
transformative action. Form objects encapsulate this responsibility.
Form objects represent the first boundary.

Boundaries are fundamental concepts in software architecture. They
determine area of responsibilities and knowledge. Dependencies also
point in one direction. Code cannot reach over the boundary and
conversely abstractions on side of the boundary do not leak to the
other side. Insert Uncle Bob Quote.  Form objects are an important
boundary Form objects are the application’s skin.  Consider your
physical skin for a moment. What does it do? First of all it is the
biggest organ your body. It keeps everything protected by keeping all
the bad stuff on the outside. The body would become infected and die
without it’s protective covering. People invest in skincare because
keeping it healthy is important. If the skin is punctured, blood
starts to leak out and bacteria or viruses may enter. The first
instinct is to patch the wound and prevent unknown things from
entering the body. Luckily our skin is self healing in a way.
Unfortunately our software is not as smart. Software engineers must
respect this boundary and actively fight to maintain it’s integrity.

Once the use case has the require input it coordinates interaction
between the other entities in the system. These are model objects most
of the time. A model represents a business object. A CRM will have
many models, most notably a customer. There will also be a user,
company, deal, task, meeting, and invoice among others. Models are the
nouns in the problem domain.  Models are for data.  A customer will
have a name, company, email, and an office address. The model
encapsulates all the semantics and exposed them in a programmatic way
to other objects. Use cases usually need to persist model data. What
good is a customer in a CRM if it cannot be retrieved later? Zero.
This leads into the very important topic of persistence.

Every application eventually needs to persist data. There are many
different approaches and libraries. Engineers usually go straight to
thinking in terms of ORM’s and data persistence systems like
PostgreSQL, MongoDB, or Redis. This usually leads to connecting the
model directly to its persisted implementation.  This is a problem
because it violates the boundary principle. Instead of focusing on how
data is persisted, it is more important to think of how it is
accessed. Once that is sorted out, treat the actual persistence as an
implementation detail.

How entities access model objects (through persisted data) is more
important than how it is persisted. The application should define a
high level interface for accessing model objects. This involves
defining intention revealing methods on an object. A CRM might have a
method like `customers_active_during(date_range)`. The method takes
the range and returns the appropriate model objects. The name adds
value and makes it easier to read.  All data queries should go through
a similar interface. This creates a boundary which hides all
implementation details. This implementation perfectly describes the
repository pattern. Matin Fowler describes the repository pattern in
“Patterns of Enterprise Architecture”. 

> A Repository mediates between the domain and data mapping layers,
> acting like an in-memory domain object collection. Client objects
> construct query specifications declaratively and submit them to
> Repository for satisfaction. Objects can be added to and removed
> from the Repository, as they can from a simple collection of
> objects, and the mapping code encapsulated by the Repository will
> carry out the appropriate operations behind the scenes.
> Conceptually, a Repository encapsulates the set of objects persisted
> in a data store and the operations performed over them, providing a
> more object-oriented view of the persistence layer. Repository also
> supports the objective of achieving a clean separation and one-way
> dependency between the domain and data mapping layers.

Fowler does not mention how they are persisted and that is very
important. A boundary is created between how the data is accessed and
how it is stored. This is very useful in practice. First of all it
allows the two abstractions to very independently. The public
interface to the collection can evolve to include access control and
more query methods. The other side can evolve to store data in an
optimal way for each use case. Consider two retrieval use cases. The
repository can lookup models by unique id or request the object graph
for a given model. The individual items may be stored in Redis for
direct access and the graphs in Neo4j. The caller has no idea how this
happens, but it does. This boundary pays dividends in so many places.
The previous example was extracted from a real world use case where
performance mattered and the data store was tailored to each use case.
This pays off big in test suites because by definition one side of the
boundary can be replaced or dropped. In the tests suite there is an
option to use an in memory or a null implementation.  Applications
suffer from slow test suites as they grow older. Using a real
persistence implementation causes most of the slow down. Unfortunately
most applications are not architected with this boundary in mind.
Removing the database is a pipe dream in these cases. This change is
very hard to retrofit.  This is a choice that will live on through an
applications’s life span. It is important to think about technical
investment and make the correct decisions up front. 

This is hard change to make because it fundamentally reverses how
application’s are commonly structured. Uncle Bob speaks about his
personal experience in his talk “Architecture, The Lost Years”. He
provides a case study about INSERT PROJECT NAME HERE. He says that
they planned on using a database early on in the process. Instead they
decided not to and stick with handling persistence in a different way.
As it turns out a database wasn’t an actual requirement. They were
able to ship the product without using a database and instead used
more simple mechanisms. “They deferred the decision off the edge of
the Earth.” Their boundary had a very small public interface. Other
people were able to implement their own persistence mechanisms very
quickly without changing any part of the broader application. Proper
concern separation empowers rapid localized changes.

Now all the parts are in place to complete a use case. What happens
next? The system must present the user some interface with the result.
What is the interface and what should the user see? Both are important
questions and can be answered with another question. What is the
delivery mechanism? Is the user on the command line, have they dialed
in via call center, or accessing via the web? Each delivery mechanism
has its own interface, however the problem domain does not change. The
problem domain and delivery mechanism lie on different sides of the
boundary. Semantics of one don’t affect the other. This requires a
core shift in development perspective. The application is not what the
user interacts with, is is the delivery mechanism used to deliver
functionality through use cases to a user in a given context. The use
cases are the heart of the application, not user facing interfaces.
Since it is the delivery mechanism’s responsibility to display the
interface, how does that happen?

It should always happen the same way, just the “what” is different.
This paper is not concerned with what is displayed but how it happens.
Displaying views can be a major technical debt sink. This is more true
for applications that use template languages not as much for desktop
or mobile applications. This is interesting. Why do template based
applications, and web applications especially, incur more technical
debt than other delivery mechanism? The answer is straight forward.
Most template languages allow some sort of logic inside them. This
usually grows to a point where the template becomes more like a
program than a template. Traditional MVC implementations (like Cocoa)
don’t have this problem because the UI element is described in code
then rendered by a library. Given that templates are ripe for
technical debt, the architecture most actively defend against it.
Logic-less views are the only true way to create a maintainable
delivery mechanism. The object responsible for drawing the UI must be
the stupidest in the entire system. There is a problem if it is not.
The delivery mechanism should instantiate a view model and the view
uses that to do its job. The view model provides everything the view
needs and that is a wrap.

Everything discussed so far is about creating proper boundaries. There
is a boundary between the delivery mechanism and the application code.
Form objects control this boundary. There is another boundary between
models and their persisted implementation. The repository object
manages this boundary. These boundaries make code easier to test and
develop because everything is decoupled. The use cases can be tested
without a delivery mechanism.  Persistence can be treated as an
implementation detail and swapped in or out during tests. New delivery
mechanisms can be created and tested in isolation as well.

So far all the layers have been discussed in the abstract. This
encourages a high level discussion but ignores the implementation.
Abstractions cannot cover all cases. Only implementing something can
illustrate how it all truly works. There are design choices that must
be made inside each layer and they all must be made correctly to
promote good design. They are only visible once you get down to the
code.

## Test Driven Implemenation

This part of the paper illustrates step by step how to properly
construct and test a system like the on previously described. The
example comes directly from real life. All aforementioned concepts are
present. However it may not make sense in the small. Every
architecture has it’s own scaling problems. Some have problems scaling
up and down. This architecture works in the small but is really target
at larger applications. Bear this in mind while reading the example.

This example deals with todos. A todo has two key items: a thing to do
and when it must be done. Todos may be assigned to different users.
User’s should receive a notification when a todo is assigned to them.
A notification is sent via email, but also transmitted over email (or
new delivery mechanisms in the future). User’s should be able to
retrieve their notifications.

All applications deal with data. We call these “models.” Use case
build use facing functionality ontop of models and their
relationships. There are three models in the described system. We have
a todo, notification, and user. It is natural to write these objects
first. Models are simple ruby classes. They declare `attr_accessors`
and define methods. There are data only. Keeping models data only has
a few key benefits. They are easy to instantiate and pass around.
Since they are easy to pass around, this makes them more reusable. It
also makes them easier to cache when object retrieval time becomes
problematic.

Defining the models is easy—simply create three new class.

    class User
      attr_accessor :name, :email
    end

    class Todo
      attr_accessor :due_date, :description, :assigned_to
    end

    class Notification
      attr_accessor :tag, :item, :user
    end

This approach may be unsettling for some. Some may be thinking: where
is the actual functionality? Where is the super class? What about
validations? Is this even OK? This is OK without a doubt. The
functionality comes from use cases which are written later. Why do is
a super class needed? Ruby provides everything needed out of the box
to define struct like classes. Input validation happens in another
place which is also covered later. If you are uncomfortable with these
points, please read on.

Take a look at those classes. What methods do they have? What do they
do? What tests should exist? The testing question is the most
interesting. These classes do not need tests as they currently are.
What value could a test provide? Any test for this class would provide
little to no value. The test would simply assert that an object had an
accessor for each property and the class was properly named. Big
whoop. Integration tests would pick up missing attributes and
incorrect names straight away. There is a rule of thumb to extract:
test code between `def` and `end` blocks. This can be pared down to
only write tests for code you write. Why could your test possibly be
better than the `attr_accessor` tests inside ruby itself. Think of it
another way: do you test methods on Ruby’s core objects or from the
standard library? The answer should be no.

Time to focus on the first (and only) use case. The requirements state
that users should be able to create new todos and receive
notifications. This interaction should be encapsulated as a single
class. The interaction can be fleshed out with tests. This also
exposes some interesting object interfaces.  Start by describing the
use case in a tests.

    class CreateTodoTest < MiniTest::Unit::TestCase
      def test_should_save_the_new_todo
        fail
      end

      def test_should_send_a_notification
        fail
      end

      def test_should_assign_the_todo_to_the_current_user_by_default
        fail
      end
    end

Writing the first use case requires the most work. The first test
states the todo should be saved (persisted). This means we must do
something with persistence. TDD puts a premium on fast tests. This
test (and all future ones) will be fast because all operations happen
in memory. The repository should be used, but it still need to be
written. The use case also needs a form object for user input.

The from object represents and sanitizes user input. This object needs
to collect three bits of information: the user, description, and due
date.  Description is a String. Due date is a Time. The class has
these readers.  Custom writers are used to handle sanitization and
conversion. The class can be driven test first.

    class NewTodoFormTest < MiniTest::Unit::TestCase
      def test_parses_a_time_from_a_string
        fail
      end

      def test_parses_integers_as_unix_times
        fail
      end

      def test_leaves_an_existing_time_object_alone
        fail
      end
    end

The tests reveal the class’ purpose. The tests are also easy to write.
Start to fill them in.

    require ‘time’

    class NewTodoFormTest < MiniTest::Unit::TestCase
      attr_reader :form

      def setup
        @form = NewTodoForm.new
      end

      def test_parses_a_time_from_a_string
        time = Time.now
        form.due_date = time.iso8601
        assert_equal time, form.due_date
      end

      def test_parses_integers_as_unix_times
        time = Time.now
        form.due_date = time.to_i
        assert_equal time, form.due_date
      end

      def test_leaves_an_existing_time_object_alone
        time = Time.now
        form.due_date = time
        assert_equal time, form.due_date
      end
    end

Next start with the class itself.

    class NewTodoForm
      attr_reader :user, :description, :due_date
    end

The tests fail at this point. `due_date=` is not implemented. Astute
readers will notice `NewTodoForm` has not be required so the test
fails for that reason as well. This detail is not relevant to the
example. If you’d like to make this an executable example then decide
on your own file structure. Implementing `due_date=` is simple.

    require ‘time'

    class NewTodoForm
      def due_date=(value)
        @due_date = case value
                    when String then Time.parse(value)
                    when Fixnum then Time.at(value)
                    when Time then value
                    end
      end
    end

This may seem like an anti-pattern. It is a bit unsettling, but very
useful.  The form itself can be reused in different context. It can
parse Time instances from strings, or integers. Strings will come from
web forms and handled correctly. Second notation may come from some
random library. The point is to illustrate input conversion and
collection. The class currently must do individual assignment. The
form accept a Hash of initial values. This enables each delivery
mechanism to capture grouped parameters in their own way dump them
into the correct object.

    class NewTodoFormTest < MiniTest::Unit::TestCase
      def test_can_be_initialized_with_a_hash
        time = Time.now
        form = NewTodoForm.new due_date: Time.now
        assert_equal time, form.due_date
      end
    end

    class NewTodoForm
      def initialize(values = {})
        values.each_pair do |name, value|
          send “#{name}=“, value
        end
      end
    end

Now it makes sense to get all the values out of the object.

    class NewTodoFormTest < MiniTest::Unit::TestCase
      def test_values_returns_all_values
        form = NewTodoForm.new due_date: Time.now
        assert_equal time, form.values.fetch(:due_date)
      end
    end

    class NewTodoForm
      def values
        { due_date: due_date, assigned_to: assigned_to, description: description }
      end
    end

Time for a small diversion. This is not required to complete the
example, but well worth it when constructing larger systems. Form
objects should be vocal about failures. From objects should raise
errors when they cannot handle input.  They should also raise a unique
error class to the caller can handle failures incorrectly. Here are
two examples. A web server could capture the error and return a 400
Bad Request response. A terminal could prompt the user to renter
values. Throwing an error forces the caller to handle a known error
condition.  The error will most likely happen when initializing the
object with a Hash.  Sending an unknown key would raise an
`UnknownMethodError`. It is easy to raise a dedicated error class.

    class NewTodoFormTest < MiniTest::Unit::TestCase
      def test_raises_an_error_when_given_unknown_fields
        assert_raises NewTodoForm::UnknownFieldError do
          NewTodoForm.new foo: ‘bar’
        end
      end
    end

    class NewTodoForm
      class UnknownFieldError < StandardError
        def initialize(field)
          @field = field
        end


        def to_s
          “You tried to set #{@field}, but it does not exist”
        end
      end
    end

This covers the first scenario. The second scenario involves type
coercion. The scenario also ensures application boundaries. The first
code implemented `due_date=`. The form should raise an error if the
given value cannot be coerced into a Time object. This ensures only
correct values make it past the border and the domain code always
works the classes it expects.

    class NewTodoFormTest < MiniTest::Unit::TestCase
      def test_raises_an_error_if_value_cannot_be_coerced_into_declared_type
        assert_raises NewTodoForm::UncoercibleValueError
          form.due_date = :foo_bar
        end
      end
    end

    class NewTodoForm
      class UncoercibleValueError < StandarError
        def initialize(value)
          @value = falue
        end
      end


      def due_date=(value)
        @due_date = case value
                    when String then Time.parse(value)
                    when Fixnum then Time.at(value)
                    when Time then value
                    else raise UncoercibleValueError, value
                    end
      end
    end

Now NewTodoForm is fully functional. Time to revisit the integration
test. The test required at least four objects: the form, model,
repository and use case.  The repository is easy to implement. Here is
an example. Further references to repository classes reference that
article. Also, the implementation is not important for this example.
Real applications need custom adapters and this outside this paper’s
scope. This paper only needs a working public interface.

A test can be written with those things in mind. Consider the first
test. It only deals with the persistence. This requires the form,
model, use case, and repo. The test passes a filled out form to the
use case, runs the use case, then asserts the repository contains the
given object.

    class CreateTodoTest < MiniTest::Unit::TestCase
      def setup
        Repo.backend = Repo::InMemoryAdapter.new
      end

      def teardown
        Repo.clear
      end

      def test_parses_a_time_from_a_string
        form = NewTodoForm.new do |f|
          f.due_date = Time.now
          f.description = ‘Finish this paper’
        end

        use_case = CreateTodo.new form
        todo = use_case.run!

        assert_equal 1, TodoRepo.count
        db = TodoRepo.first

        assert_equal form.due_date, db.due_date
        assert_equal form.description, db.description
      end
    end

    class CreateTodo
      def initialize(form)
         @form = form
      end

      def run!
        todo = Todo.new

        todo.due_date = form.due_date
        todo.description = form.description

        TodoRepo.save todo

        todo
      end

      private
      def form
        @form
      end
    end

Somethings require a short description. The setup and teardown methods
wipe all data. Since all data is stored in memory this operation is
o(1) and causes no performance impact. CreateTodo implements all logic
inside `run!`. It also assumes the happy path. Errors represent
failure conditions. `TodoRepo.save` will raise an error if the adapter
cannot persist the record. The caller must handle the error.
Unfortunately an error that far down in the stack is probably not
rescueable. It never be ignored though. This is better than having
methods that may raise errors (example: save vs save! in
ActiveRecord). This is a design decision more than anything else.
Methods should only have one outcome: success. They should raise an
error otherwise.

The implementation leaves a few things to be desired. Assigning
individual values (due_date, and description) will certainly become
annoying when the model has more attributes. It may make sense to
define an `attributes=` method for setting multiple fields at once.
This works when there is a direct connection between fields in the
form and fields in the model. Eventually the connection goes away and
the form contains use case specific information (do you want this or
that?) then `values.without(:some_key)` happen. This may be a problem
for you. You must decide which approach works for you.

`TodoRepo.save` is also unneeded. The repo implementation explains how
to create a TodoRepo and have the Todo class talk to the TodoRepo.
`TodoRepo.save` is here to make it obvious the repo is persisting data
and not the model itself. Once that’s clear it is more aesthetically
pleasing to use the Repo::Delegation module described in the
implementation. Then `TodoRepo.save` may be replaced with `todo.save`.
`todo.save` is preferable because it hides some of the implementation.

The code fulfills the simplest use case: a todo can be created and
persisted in the system. The code does not handle nonhappy-path
scenarios. What happen’s when the user does not fill out the form? The
form must be validated before the use case can continue. Implementing
validation logic is a surprisingly complex.  The implementation
depends on how responsibilities are defined and how input is
collected.

Naturally there are many different ways to implement input validation.
The logic could be implemented in a few places. The form class could
handle its own validations. This may violate the single responsibility
principle depending on how the form’s responsibilities are defined.
Should the form handle input collection, sanitization, and input
validation? This is a good question. There is not a definite answer.
Assume this violates the single responsibility principle, the next
step is creating a validator class. Validating input is its single
responsibility. This implementation will create duplication. There are
fields in the model, form, and validator class. On the other hand, a
validator instance can be passed around and reused in the entire
system context free.  Perhaps this seems weird. Isn’t this a
responsibility for the model itself.  Surely that is the only object
that truly knows what data it can have so it would makes sense to
implement validation in the model. However is this not violation of
the single responsibility principle for the same reason implementing
it on the form was? A case can be made either way. The situation
becomes more complicated when non model data requires validation.
Consider this scenario. A use case in the system optionally sends an
email notification based on a flag. The data is not persisted but
simply used in a one time off way, thusly there is no need for a model
object. This validation logic must be implemented on the form because
that’s the only object that knows it’s purpose and context. If this
use case happens is it a good idea if the logic had previously been
implemented on the model or in a separate class? This is another good
question. Answers to all these questions also depend on how the input
is collected. Should forms always be filled out completely or are
partial forms allowed? This depends on how create and update use cases
are handled. All data is required to create a record. Updates are
different. Do updates require the full data set or are partial updates
allowed? If the form implements validations then how does that work in
the partial update use case? That set up doesn’t work. It would work
fine if updates required all the data, but is that a useful
requirement? If the model implements validations then create, partial
update, and complete update work because the validation subject has
all the correct attribute values. Then we’re right back to the same
question, is this good design?

Implementing a correct validation architecture means answering many
questions.  The correct implementation depends on the application and
it’s use cases. This paper cannot answer all of those questions. It
does provide examples and hopefully make decision making easier. This
paper’s example is a focused use case and uses a validation strategy
that works for this specific use case.

This example implements validations on the form objects. The form
objects are the boundary between the application and the horrible
world outside. Once data makes it passed the form it should not be
checked anywhere in the system. This does not violate the single
responsibility principle. Implementing validation on the form is
preferable for other reasons. It does not duplicate code like using a
validator object would. It also scales up to future users where their
is form/use case specific data that must be validated. The
implementation also keeps the model data only. However the form must
be 100% complete otherwise validation will fail. This is an acceptable
tradeoff.

Writing a test drives out the functionality easily. The test calls the
use case with a form containing invalid data and assert on some
result. What is the result? This opens up another discussion on what
use case objects should return. `CreateTodo#run!` returns the todo
object. This is an sensible approach in the happy path case. What
about a validation failure? This is scenario is very likely. How many
times have you submitted an incorrect form? Probably plenty of times
for it frustrate you. Since the scenario is likely and also important
to the overall application there must be a sensible approach. A well
designed application will handle the scenario and present the user
with some options to continue the interaction. It is sensible that the
code itself enforces this principle. Raising an exception does all the
things. Raising an exception requires the caller handle it otherwise
the application will crash.  Sensible programs will handle the
exception and react accordingly. This also has a few other side
effects. The code interacting with the use cases (the delivery
mechanism) reads easily because it is focuses on the happy path. It
also makes the caller prepare for error conditions (not just
validation failures) and implement the proper handling mechanism. It
also makes code vocal and stronger in a sense.

The use case requires two methods: one to check if the form is valid,
and one to return the errors. Now that all the requirements are known
the test can be created.

    class CreateTodoTest < MiniTest::Unit::TestCase
      def test_raises_an_error_when_given_invalid_data
        # create a blank form
        form = NewTodoForm.new

        use_case = CreateTodo.new form

        assert_raises ValidationError do
          use_case.run!
        end
      end
    end

Then the use case itself.

    class CreateTodo
      def initialize(form)
         @form = form
      end

      def run!
        raise ValidationError, form.errors unless form.valid?

        todo = Todo.new

        todo.due_date = form.due_date
        todo.description = form.description

        TodoRepo.save todo

        todo
      end

      private
      def form
        @form
      end
    end

The tests fails now for two reasons: the form does not implement the
validation interface and ValidationError is not defined. Time to
implement validation in the form.

    class NewTodoForm
      def valid?
        description && due_date
      end


      def errors
        “description or due date missing”
      end
    end

This is a simple implementation. The both methods are hard coded to
two specific fields. It would not scale up to more fields or more
validation rules.  This is not relevant to the example. The example
only requires a validation interface. It doesn’t matter what happens
behind the interface. This code would never make it into production as
well. A library would be used in the real world. Now the example
handles input validation. It is becoming more robust one step at a
time.

The system must also send a notification. Let’s expand the example to
cover more concepts. The original requirement was to send a
notification when a new task was added. That’s changing. The system
should send a notification whenever a new task is created or an
existing task is reassigned. The notification should contain who added
the task or who reassigned it. This creates an interesting
requirement. The notification code must know who did it (the current
user) and who to send it to. It is not good design to assign current
user on stateless objects. The current user represents state and it
must kept as close to the boundary as possible. It cannot leak down
into other objects.  So should we implement this? The
publish/subscribe patterns works well here.  The model itself is only
object that knows if it has been reassigned. The model publishes an
event when that happens. The use case can attach an observer along
with state and pass it along. The observer pattern works well here.

Creating the observer is easy. Simply create a class and implement a
method.  The method takes all the arguments required to send the
notification.

    class TodoObserver
      def assigned(todo, assigned_to, current_user)
        # Do stuff here
      end
    end

Now to tackle the model. The model needs a method that does logic and
publishes events. It also needs an interface to attach observers. The
model already implements a save method. The event logic goes here. The
ruby standard library provides the Observable module. There is also
some miscallenous methods needed to make this all work. The example
assumes some methods exist, however their implementation is outside
the example’s scope. A test is provided as an example, but it would
work without implementing the missing code. Here is the test.

    def test_emits_an_when_a_new_record_is_created
       observer, assigned_to = mock, mock

       todo = Todo.new description: ‘Test’, due_date: Time.now, assigned_to: assigned_to
       todo.add_observer observer

       observer.should_receive(:assigned).with(todo, assigned_to)

       todo.save
    end


    def test_emits_an_event_when_an_existing_todo_is_reassigned
       observer, previously_assigned_to, currently_assigned_to = mock, mock, mock

       todo = Todo.new description: ‘Test’, due_date: Time.now, assigned_to: previously_assigned_to 
       todo.save

       todo.add_observer observer

       observer.should_receive(:assigned).with(todo, currently_assigned_to)

       todo.assigned_to = currently_assigned_to

       todo.save
    end

Now the model implementation

    class Todo
      include Observable


      def new_record?
        !!id
      end


      def save
        was_new_record = new_record?

        super

        if was_new_record || (!was_new_record && assigned_to_changed?)
          changed
          notify_observers self, assigned_to
        end
      end

      private
      def assigned_to_changed?
        # TODO: implement this
        false
      end
    end

Astute readers will notice that implementation is stateless. The use
case is the only object that contains state. It connects the stageful
and stateless parts of the application. In order for this to the work,
the use case takes in who the current user is and passes it along to
objects that need it. Once that’s there it’s easy to write a test and
complete the implementation.

    class CreateTodoTest < MiniTest::Unit::TestCase
      def test_sends_a_notification
        bob = User.create name: ‘Bob’
        tom = User.create name: ‘Tom'

        form = NewTodoForm.new do |f|
          f.due_date = Time.now
          f.description = ‘Finish this paper’
          f.assigned_to = bob
        end

        use_case = CreateTodo.new form, tom
        todo = use_case.run!

        assert_equal 1, NotificationRepo.count
        db = NotificationRepo.first

        assert_equal todo, db.todo
        assert_equal tom, db.from
        assert_equal bob, db.user
      end
    end

Now the use case.

    class CreateTodo
      attr_reader :current_user

      def initialize(form, current_user)
         @form, @current_user = form, current_user
      end

      def run!
        raise ValidationError, form.errors unless form.valid?

        todo = Todo.new

        todo.due_date = form.due_date
        todo.description = form.description

        todo.add_observer self

        todo.save

        todo
      end

      def assigned(todo, assigned_to)
        NotificationSevice.send_todo_notification todo, assigned_to, current_user
      end

      private
      def form
        @form
      end
    end

That’s all there is to it! The NotificationService must implement the
notification creation logic, but that is trivial. This example is not
about implementing all the code, but illustrating the interface
between different objects and their roles. The observer pattern is a
perfect way to publish domain events. Objects can listen to them and
propagate their meaning throughout the system. This implementation
also ensures the models follow the SRP. The models do not implement
any behavior, but make it possible for others.  The use case takes in
state and passes it around. It ensures that all the objects perform in
concert.
