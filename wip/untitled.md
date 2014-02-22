---
title: Untitled
layout: post
---

**Abstract**: This paper describes an application architecture that
maximizes long term maintainability and feature deliverability for a
certain class of applications. It covers effective boundary use,
application roles, and design patterns to create an architecture that
separates the core business logic from the delivery mechanisms and
external concerns. Problems with current approaches highlighted as
well. It finishes with a migration strategy for existing applications.

--------------------------------------------------------------------

## Effective Design & Technical Investment

Effective software design focuses on enforcing boundaries and applying
design patterns. Maintainable systems have boundaries in the right
places. Design patterns organize code in predictable and
understandable ways. Both strategies actively defend against technical
debt and encourage technical investment. It is common knowledge that
smart investments lead to long term success. Software engineering is
no different. Investments must be made in an application's
architecture to maximize its long term success, feature
deliverability, and scalability. It is time to apply the same long
term financial planning to software applications.

Technical debt is the cost of previous engineering decisions.
Implemenations can be quick and dirty or executed to meet current
needs and also setup the next iteration. This illustrates the choice:
quick and messy, or slow and clean. Every programmer has made
this decision "oh, I'll just hack this in” then written FIXME directly
above it." Then probably thought to themselves how to implement it
correctly. Applications routinely collapse under their technical debt.
Applications become impossible to maintain. Iterations become longer,
estimates become impossible, and developer happiness
plummets. In the worst case, starting over is the only way to repay
the debt. This is an unfortunate but avodiable. This
happens when engineering teams (for whatever reason) decide
to accumulate more technical debt. The decision usually comes from
business requirements and short delivery dates. Teams must actively
decide to pay back debt in terms of technical investments.
Projects incur most technical debt in the early stages. This is the
most delicate time in an application's life time. Just like real life
childhood, the decisions (good, bad, and ugly) made in the formative
years have a strong lasting impact. The signs of excellent parenting
live on and people grow into well adjusted individuals. Horrible or
abusive parenting often leave scars for life which are difficult or
impossible to heal without serious effort. This paper is about making
technical investment in software architecture from time zero to raise a
happy, mature, and maintainable programs. Children need proper
nourishment from the beginning. Applications require proper separation
of concerns, boundaries, objects roles, and design patterns.

Architecting applications means constructing boundaries, defining
interactions, decoupling, and arranging objects in extendable ways.
Applications are often tightly coupled to their delivery mechanism.
This is a pain point since it is hard to extend existing code bases.
It also affects testability and blurs the line between core business
and presentation logic. Arranging objects is the most difficult part.
*Possible Sandi Metz quote*. This paper demonstrates an object
arrangement that exemplifies all the important characteristics of a
maintainable and extendable application. Creating good software
requires heavy focus on its core functionality. We call know them as
use cases.

## Use Cases: Heart of the System

A use case describes something a system does. It is a unit of work. A
CRM (Customer Relationship Management) system has use cases like
“create customer”, “invoice customer”, or “contact customer.” A
classifieds site like Craigslist has uses cases such as “post ad” or
“contact seller.” Use cases are things users can do. They are a
systems's core. Use cases have alternate flows and are often composed
into more complex flows. A CRM may want to add a customer then contact
them. This is possible when implemented correctly and down right
painful when not. Use cases are usually not straight forward. They
must interact with many other entities in the system. They are
conductors orchestrating the interaction between all the other
entities in the system. A use cases takes in some form of input and
takes appropriate action. The input is examined and some records are
created or modified. Perhaps some external state is modified (like
talking to an external service or a RDMS). Eventually the user is
presented with some interface showing the result of this interaction.
This is how software fundamentally it works. It all starts with
handling user input.

Handling user input is one of the most boring task's for programmers.
It always seems like unimportant work. Input must always be checked,
sanitized, and validated. The same type of code has been written
millions of times across the globe. Eventually this part of the work
is done and we can get back to the real meat of the problem. Handling
user input is actually extremely important to an application’s long
term health. Proper input checking makes code more confident. Avdi
Grimm used this term in his book "Confident Ruby".  *Insert Avdi Quote
here*. He describes unconfident code as between too focused on edge
cases and input handling and that happening in many parts of the code.
Confident code does not have this problem. It knows what it has and
what to do. Proper input sanitization makes this possible. User input
should be checked and sanitized before it enters the system and never
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

The paper focused on abstract concepts until this point. It is time to
deal in concrete implementations. This section describes a general
code structure and implementation. All roles and boundaries are
covered. The code examples are **not** directly executable. The
examples are a push into the right direction. The example requirements
have been specifically choosen to illustrate concepts and basic
implementations.

This use case is taken directly from a CRM. The example revolves
around creating todos. A todo is a description and a due date. Todos
may optionally be assigned to users. Descrition and due date are
required. Adding todos also sends notifications. The system should
send a notification when a user adds a todo for someone else. The
system should also send a notification when an existing todo is
assigned to a different user. New todos should be assinged to the
current user by default.

The previous paragraph describes a two use cases. Users can add new
todos. They can also update existing todos. There are other models
besides todos. There is a user and notification model. Each will have
its own class.

The use case tests can be driven outside in. This focuses on testing
high level functionality. Unit tests handle more specific
interactions. The test process begins with a failing use case test.

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

The test fails and rightfully so. The tests are coded to fail and the
required objects are not defined yet. What is the next step? The first
test must be filled in. What would the test look like?

All programs follow the same general procedure: 1) collect input, 2)
sanitize & validate input, 3) perform logic, 4) return the result.
The test reveals itself using that as a guide. It requires a form (to
collect input), a use case to process it, then assertions on the
result.

    def test_should_save_the_new_todo
      user = User.new 'bob'
      form = TodoForm.new description: 'finish this paper', due_date: Time.now
    end

The test fails because there is no `User` class. The use case requires
todos assigned to users. This is the first requirement. It is a model
class and natural starting place.

Models encapsulate data. Use cases manipulate and coordinate their
interactions. This means the models do not contain any related
behavior. A model only knows about itself and it's data. Expressing
models is easy in Ruby. Delcare a class and add the proper accessors.

    class User
      attr_reader :name

      def initialize(name)
        @name = name
      end
    end

Examine the class for a moment. What does it do? The class
encapsulates the user concept. It simply provides access to the data.
What it does not do is more important. It has no persistance logic. It
does not have any validation logic either. Models are data and they
must be kept that way. The code is very simple. It is arguable that
the code requires tests at all. The example focuses on todos and
not users. The test would provide no value. The use case test 
would catch an error in the `User` class. Therefore a test for the
`User` class can be skipped. The use case test now fails because
`TodoForm` is not defined. Time to focus on the input boundary.

`TodoForm` is a border guard. It's responsibility to
ensure all data is acceptable and reject anything that's not.
Implementing the class is straight forward. The class has accessors
for all the data it must collect.

    class TodoForm
      attr_accessor :description, :due_date, :assigned_to
    end

This is not enough to make the test pass. The initializer takes a hash
of values. This is easy to implement.

    class TodoForm
      attr_accessor :description, :due_date, :assigned_to

      def initialize(values = {})
        values.each_pair do |key, value|
          send "#{key}=", value
        end
      end
    end

Is this correct though? The previous code works well when the input
values are controlled. However this class is exposed to the outside
world where input is not controller. What if `assigned_to` was a
`Time` instance and `due_date` was a `User` instance? If that happens
the class would fail it's single responsibility. The form must gaurd
against such conditions. A test is perfect for describing
responsibilities.

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

The tests illustrate sanitization. The test ensures the form provides
the correct objects. Forms must provide the correct data types.
Writing tests is easy. Instantiate a form, assign the value, then
assert on the result.

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

The test fails because the coercion logic is missing. Defining the
proper `due_date=` method on `TodoForm` makes the test pass.

    require ‘time'

    class TodoForm
      def due_date=(value)
        @due_date = case value
                    when String then Time.parse(value)
                    when Fixnum then Time.at(value)
                    when Time then value
                    end
      end
    end

This may seem like an anti-pattern. It is a bit unsettling, but very
useful.  The form itself can be reused in different context.s It can
parse `Time` instances from strings, or integers. Strings will come
from web forms and assign correctly. Seconds may come from some random
library. The point is to illustrate input conversion and collection.
The form accept a `Hash` of initial values. This enables each delivery
mechanism to capture grouped parameters in their own way dump them
into a form object.

The border is not strong enough. It does not handle error scenarios.
There are two notable problems. The initializer does not handle
unknown values. Secondly, `due_date=` does not handle uncoercible
values. These are failure conditions and should be treated as such.
The border must be protected. The code should raise an exception in
these cases. This is very useful in integration tests and when
implementing delivery mechanisms. The delivery mechanisms can rescue
the error and react accordingly. Raise an error in the first case
asserts invalid data never makes into the wider system.

    def test_raise_an_error_when_initializing_with_unknown_attribute
      assert_raises TodoForm::UnknownAttributeError do
        TodoForm.new foo: :bar
      end
    end

    def test_raises_an_error_when_cannot_handle_due_date
      assert_raises TodoForm::UncoercibleValueError do
        form.due_date = :bar
      end
    end

Raising an error in the correct place ensures the test passes.

    class TodoForm
      UncoercibleValueError = Class.new ArgumentError
      UnknownAttributeError = Class.new ArgumentError

      def initialize(values = {})
        values.each_pair do |key, value|
          if respond_to? "#{key}="
            send "#{key}=", value
          else
            raise UnknownAttributeError, key
          end
        end
      end

      def due_date=(value)
        @due_date = case value
                    when String then Time.parse(value)
                    when Fixnum then Time.at(value)
                    when Time then value
                    else
                      raies UncoercibleValueError, value
                    end
      end
    end

Now the border is strong. That completes the basic implemenation
showing the concepts. An `assigned_to=` method will need
implementation at some point. Unfortunately the method requires
persistence to work so punt on that. The input boundary is finished.
Time to return to the failing use case test.

The form and user model are ready. Now the use case's implementation
reveals itself. The use case uses the form to create a todo.

    class CreateTodoTest < MiniTest::Unit::TestCase
      def test_should_save_the_new_todo
        user = User.new 'bob'
        current_user = User.new 'adam'

        form = TodoForm.new description: 'finish this paper', due_date: Time.now
        use_case = CreateTodo.new form, current_user

        use_case.run!
      end
    end

The test documents the interface. A use case takes two arguments: the
form and the current user. `CreateTodo#run!` executes the use case.
The test does not include any assertions on the use case's output.
This is problem because the test does not provide real value in its
current form. The test's naem is `test_should_save_the_new_todo`. This
implies persistance.

The repository pattern handle's persistance. The repistory separates
data access and persistence. It provides the models as if they were a
simple collection. The boundary means implementations are swappable.
The tests can use a simple in memory store and other code something
moer specific to it's needs. This ensures the tests stay fast because
no external resources are used. Since the implemenations are swappable
it is also possible to run the same test suite using a different
adapter in a continous integration environment. Implementing the
repository is outside this example's scope. The code assumes a simple
interface based on this *implementation (insert link)*. Once again,
the code examples are not to show 100% of the implementation. The
examples demonstrates how to write tests and the interface btween
objects. Therefore the internal implemenation is not important. Now
that the reposistory is ready add persistence assertsions to the test.

    class CreateTodoTest < MiniTest::Unit::TestCase
      def test_should_save_the_new_todo
        bob = User.new 'bob'
        current_user = User.new 'adam'

        form = TodoForm.new({
          description: 'finish this paper',
          due_date: Time.now,
          assigned_to: bob
        })

        use_case = CreateTodo.new form, current_user

        todo = use_case.run!

        assert_equal 1, TodoRepo.count
        db = TodoRepo.first

        assert_equal todo.due_date, db.due_date
        assert_equal todo.description, db.description
        assert_equal todo.assigned_to, db.assigned_to
      end
    end

The test fails because `CreateTodo` is not defined. Implementing use
cases is straight forward. Define a new class that takes in two
arguments: a form and the current user. The `run!` method does all the
required logic. The use case returns the newly created todo.

    class CreateTodo
      attr_reader :form, :current_user

      def initialize(form, current_user)
        @form, @current_user = form, current_user
      end

      def run!
        todo = Todo.new

        todo.due_date = form.due_date
        todo.description = form.description
        todo.assigned_to = form.assigned_to

        TodoRepo.save todo

        todo
      end
    end

The test passes at this point. However the tests only cover the most
baisc scenario. Only the happy path is covered. The use case does not
send any notifications yet either. The test still contains failing
tests. Focus on these before implementing the next level
functionality. Go for low hanging fruit first. The third test is
easier. The test ensures the use case assigns the todo to the current
user by default. Writing the test is easy. Omit `assigned_to` from the
form then assert the todo is assigned to the `current_user`.

      def test_should_assign_the_todo_to_the_current_user_by_default
        bob = User.new 'bob'
        current_user = User.new 'adam'

        form = TodoForm.new({
          description: 'finish this paper',
          due_date: Time.now
        })

        use_case = CreateTodo.new form, current_user

        todo = use_case.run!

        assert_equal 1, TodoRepo.count
        db = TodoRepo.first

        assert_equal current_user, todo.assigned_to
      end

The test fails because the use case does not handle the case yet. This
is a trivial fix with the `||=` operator.

    class CreateTodo
      attr_reader :form, :current_user

      def initialize(form, current_user)
        @form, @current_user = form, current_user
      end

      def run!
        form.assigned_to ||= current_user

        todo = Todo.new

        todo.due_date = form.due_date
        todo.description = form.description
        todo.assigned_to = form.assigned_to

        TodoRepo.save todo

        todo
      end
    end

A simple one line change makes the test pass. The use case is
approaching feature completeness. However, the implementation leaves a
few things to be desired. Assigning individual values (`due_date`,
`description`, and `assigned_to`) will certainly become annoying when
the model has more attributes. It may make sense to define an
`attributes=` method on the model and `values` on the form for setting
multiple fields at once. This works when there is a direct connection
between fields in the form and fields in the model. Eventually the
connection goes away and the form contains use case specific
information (do you want this or that?) then
`form.values.without(:some_key)` happen. This might cause a problem.
Keep this in mind going forward.

There is one test remaining. The test ensures a notification is sent
to the user. A notification has three attributes: the user who sent
it, the receiving user, and what the notification is about. The test
follows the same structure. Instead of asserting on todo presence,
assert on notification presence.

    class CreateTodoTest < MiniTest::Unit::TestCase
      def test_should_send_a_notification
        bob = User.new 'bob'
        current_user = User.new 'adam'

        form = TodoForm.new({
          description: 'finish this paper',
          due_date: Time.now,
          assigned_to: bob
        })

        use_case = CreateTodo.new form, current_user

        todo = use_case.run!

        assert_equal 1, NotificationRepo.count
        db = Notification.first

        assert_equal bob, notification.to
        assert_equal current_user, notification.from
        assert_equal todo, notification.about
      end
    end

The test fails because `Notification` is not defined. This is another
model class. It's defined in the same way as `User` or `Todo`.

    class Notification
      attr_accessor :to, :from, :about
    end

The test fails because a notification is never created. The failing
assertions means it is time to write some code. This test is not as
straight forward as the other. It requires some thought upfront.

This reuqirement exposes interesting design decisions and other
boundaries. The notification code must know who did it
(the current user) and who to send it to. It is not good design to
assign current user on stateless objects. The current user represents
state and it must kept as close to the boundary as possible. It cannot
leak down into other objects.

How should this be implemented? The publish/subscribe pattern works
well here. The model is only object that knows if it has been
reassigned. The model publishes an event when that happens. The use
case can attach an observer along with state and pass it along.

Creating the observer is easy. Simply create a class and implement a
method. The method takes all the arguments required to send a
notification.

    class ExampleObserver
      def assigned(todo, assigned_to, current_user)
        # Do stuff here
      end
    end

The model needs a method that does logic and publishes events. It also
needs an interface to attach observers. The ruby standard library
provides the `Observable` module. There is also some miscallenous
methods needed to make this all work. The example assumes some methods
exist, however their implementation is outside the example’s scope. A
test is provided as an example, but it would work without implementing
the missing code.

    class TodoTest < MiniTest::Unit::TestCase
      def test_emits_an_when_a_new_record_is_created
        observer, assigned_to = mock, mock

        todo = Todo.new description: ‘Test’, due_date: Time.now, assigned_to: assigned_to
        todo.add_observer observer

        observer.should_receive(:assigned).with(todo, assigned_to)

        todo.save
      end

      def test_emits_an_event_when_an_existing_todo_is_reassigned
        observer, previously_assigned_to, currently_assigned_to = mock, mock, mock

        todo = Todo.new({
          description: ‘Test’,
          due_date: Time.now,
          assigned_to: previously_assigned_to
        })

        todo.add_observer observer

        todo.save

        observer.should_receive(:assigned).with(todo, currently_assigned_to)

        todo.assigned_to = currently_assigned_to

        todo.save
      end
    end

Next for the model.

    class Todo
      include Observable

      def new_record?
        !!id
      end

      def save
        was_new_record = new_record?

        TodoRepo.save self

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
case is the only object that contains state. It connects the stateful
and stateless parts of the application. In order for this to the work,
the use case takes in the current user is and passes it along to
objects that need it. The use case is still failing at this point.
`CreateTodo` must be modified to complete it.

    class CreateTodo
      attr_reader :current_user, :form

      def initialize(form, current_user)
         @form, @current_user = form, current_user
      end

      def run!
        form.assigned_to ||= current_user

        todo = Todo.new

        todo.due_date = form.due_date
        todo.description = form.description
        todo.assigned_to = form.assigned_to

        todo.add_observer self

        todo.save

        todo
      end

      def assigned(todo, assigned_to)
        notification = Notification.new
        notification.about = todo
        notification.to = assigned_to
        notification.from = current_user
        NotificationRepo.save notification
      end
    end

Now the test passes. The same implementation also applies when
updating existing todos. This illustrates the separation of event
propagation and event handling. The observer pattern is a powerful way
to publish domain events. Use cases capture the events and delegate
them to other entities in the system. This keeps models singularly
focused on data.

Now the code fulfills all the happy path requirements. What happen’s
when the user does not fill out the form? The form must be validated
before the use case can continue. Implementing validation logic is
surprisingly complex. The implementation depends on how
responsibilities are defined and how input is collected.

Naturally there are many different ways to implement validation.  The
logic may be implemented in a few places. The form could handle its
own validations. This may violate the single responsibility principle
depending on how the form’s responsibilities are defined.  Should the
form handle input collection, sanitization, and input validation? This
is a good question. There is not a definite answer.  Assuming this
violates the single responsibility principle and therefore should be
avoided, the next step is creating a validator class. Validating input
is a single responsibility. This implementation will create
duplication. There are fields in the model, form, and validator class.
On the other hand, a validator instance can be passed around and
reused in the entire system context free. Perhaps this is weird. Is it
not the model's responsibility? Surely that is the only object that
truly knows what data it can have so it would makes sense to implement
validation there. However is this not violation of the single
responsibility principle for the same reason implementing it on the
form was? This is debatable. The situation becomes more complicated
when non model data requires validation.  Consider this scenario. A
use case optionally sends an email notification based on a flag. The
data is not connected to a modle but simply used in a one off way.
The form must implement validation because only it knows the purpose
and context. If this use case occurs, is it a good idea if the logic
had previously been implemented on the model or in a separate class?
This is another good question. Answers to all these questions also
depend on how the input is collected. Should forms always be filled
out completely or are partial forms allowed? This depends on how
create and update use cases are handled. All data is required to
create a record. Updates are different. Do updates require the full
data set or are partial updates allowed? If the form implements
validations then how does that work in the partial update use case?
That set up doesn’t work. It would work fine if updates required all
the data, but is that a useful requirement? If the model implements
validations then create, partial update, and complete update work
because the validation subject has all the correct attribute values.
Then we’re right back to the same question, is this good design?

Implementing validation architecture correctly requires answering all
these questions. The correct implementation depends on the application and
its use cases. This paper cannot answer all of those questions. It
does provide examples and hopefully makes a decision easier. This
paper’s example is a focused use case and uses a validation strategy
that works for this specific use case.

This example implements validations on the form objects. The form
objects are the boundary between the application and the horrible
world outside. Once data makes it past the form it should not be
checked anywhere in the system. This does not violate the single
responsibility principle. Implementing validation on the form is
preferable for other reasons. It does not duplicate code like using a
validator object would. It also scales up to future uses where there
is form/use case specific data that must be validated. The
implementation also keeps the model data only. However the form must
be 100% complete otherwise validation will fail. This is an acceptable
tradeoff.

Writing a test drives out the functionality easily. The test calls the
use case with a form containing invalid data and asserts on some
result. What is the result? This opens up another discussion on what
use case objects should return. `CreateTodo#run!` returns the todo
object. This is an sensible approach in the happy path case. What
about a validation failure? This is a common scenario. How many
times have you submitted an incorrect form? Probably enough times
for it frustrate you. Since the scenario is likely and also important
to the overall application there must be a sensible approach. A well
designed application will handle the scenario and present the user
with some options to continue the interaction. It is sensible that the
code itself enforces this principle. Raising an exception does all the
things. Raising an exception requires the caller handle it otherwise
the application will crash. Sensible programs will handle the
exception and react accordingly. This also has a few other side
effects. The code interacting with the use cases (the delivery
mechanism) reads easily because it is focuses on the happy path. It
also makes the caller prepare for error conditions (not just
validation failures) and implement the proper handling mechanism. It
also makes code vocal and more confident.

The use case requires two methods: one to check validity and one to
return the errors. Now that all the requirements are known the test
can be created.

    class CreateTodoTest < MiniTest::Unit::TestCase
      def test_raises_an_error_when_given_invalid_data
        # create a blank form
        form = TodoForm.new
        use_case = CreateTodo.new form

        assert_raises ValidationError do
          use_case.run!
        end
      end
    end

Implementing the use case is straightforward.

    class CreateTodo
      def run!
        form.assigned_to ||= current_user

        raise ValidationError, form.errors unless form.valid?

        # existing code ...
      end
    end

The tests fails for two reasons: the form does not implement the
validation interface and ValidationError is not defined. Time to
implement validation in the form.

    class NewTodoForm
      def valid?
        description && due_date && assigned_to
      end

      def errors
        "description, due_date, and assigned_to are required"
      end
    end

This is a simple implementation. The both methods are hard coded to
two specific fields. It would not scale up to more fields or more
validation rules. This is not relevant to the example. The example
only requires a validation interface. It doesn’t matter what happens
behind the interface. This code would never make it into production as
well. A library would be used in the real world. Now the example
handles input validation. It is becoming more robust one step at a
time.

The application is now roboust enough to handle a real user. How does
the user access the application? The code does not collect input from
standard input or any other source. So how does anything actually
happen? This is the delivery mechanism's responsibility.

## Implementing a Delivery Mechanism

The delivery mechanism handles all the user and context specific
requirements. Condiser two different HTTP delivery mechanisms, one
that deals with HTML and one with JSON. The JSON version will
communicate errors via HTTP status code. The HTML version will display
forms and have a different user experience. This is possible because
the core application logic is independant from the delivery mechanism.

This examples creates an JSON API delivery mechanism using Sinatra.
The code is straight forward and the concepts shine through. It also
easier to test since there is no user facing behavior.

The delivery mechansim is simple. It accepts an HTTP POST with the
required paramaters and creates a todo. The server returns a todo in
JSON for consumption.

The first test covers the happy path scenario.

    class WebServiceTest < MiniTest::Unit::TestCase
      include Rack::Test::Methods

      def app
        WebService
      end

      def test_returns_json_when_the_todo_is_created
        flunk
      end
    end

Now the question is: what actually goes into this test? The test is
similar to the one in `CreateTodoTest`. The test needs to create at
least one user, post some data, and assert on the response. The
application also needs some way to know who the current user is. The
current user must be configurable in the tests. In the real world
their would be real authentication. It is safe to assume that some
other piece of code will take care of that an provide the current
user. Therefore the tests can implement a fake authentication scheme.
The rest is straight foward.

    class WebServiceTest < MiniTest::Unit::TestCase
      include Rack::Test::Methods

      def app
        WebService
      end

      def test_returns_json_when_the_todo_is_created
        adam, peter = User.create('Adam'), User.create('peter')

        post("/todos", {
          todo: {
            description: 'Finish this test',
            due_date: Time.now.iso8601,
            assigned_to: 'peter'
          }
        }, { 'current_user' => adam })

        assert 201, last_response.status
        assert_equal 'application/json', last_response.content_type
      end
    end

This is enough to get started. The test fails right off the bat
because `WebService` does not exist.


    require_relative 'todo_form'
    require_relative 'create_todo'

    require 'sinatra'

    class WebService < Sinatra::Application
    end

Notice the class requires the form and use case. The delivery
mechansim must load its required classes. In practice the may live in
a separate gem or repository. Now the test fails because "/todos" does
not exist.

    class WebService < Sinatra::Application
      post "/todos" do

      end
    end

Running the test again shows the first failing assertion. The test
fails because the response code incorrect. Time to fill in the route
handler with actual code.

    class WebService < Sinatra::Application
      post "/todos" do
        form = TodoForm.new params['todo']
        use_case = CreateTodo.new form, current_user

        todo = use_case.run!
      end
    end

The test is still failing. There are still more things to fill in. The
application does not defined the `current_user` method.

    class WebService < Sinatra::Application
      helpers do
        def current_user
          env.fetch 'current_user'
        end
      end
    end

That takes care of that failure. Setting the current user through the
`env` hash makes it easy to test. Running the test again does not
produce an error but an assertion failure. The delivery mechanism does
not return JSON.

    require 'json'

    class WebService < Sinatra::Application
      post "/todos" do
        form = TodoForm.new params['todo']
        use_case = CreateTodo.new form, current_user

        todo = use_case.run!

        content_type 'application/json'

        JSON.dump({
          todo: {
            id: todo.id,
            description: todo.description,
            due_date: todo.due_date.iso8601
          }
        })
      end
    end

Now the test passes, but it does not have meaningful assertions.

    def test_returns_json_when_the_todo_is_created
      adam, peter = User.create('Adam'), User.create('peter')

      post("/todos", {
        todo: {
          description: 'Finish this test',
          due_date: Time.now.iso8601,
          assigned_to: peter.id
        }
      }, { 'current_user' => adam })

      assert 201, last_response.status
      assert_equal 'application/json', last_response.content_type
      json = JSON.load(last_response.body).fetch 'todo'

      assert json.key?('id'), "JSON should contain the todo id"
      assert json.key?('due_date'), "JSON should contain the due date"
      assert json.key?('description'), "JSON should contain the description"
      assert json.key?('assigned_to'), "JSON should contain who the todo is assigned to"
    end

Now the test fails on the final assertion. The form does not know how
to lookup a user. It is not possible to send `User` instances over
HTTP. The request can only reference an identifier (such as a unique
id). The application sends the user's name. The form must implement
this behavior. The form already contains an example of how to parse
times. Astute readers will not that the time is sent in ISO8601
format. This format is easy to ready by humans and Ruby parses it
correctly out of the box. This way the form provides a `Time` object
to all its collabators. The form can do the same thing for
`assigned_to`.

    class TodoForm
      def assigned_to=(value)
        case value
        when User then value
        when String then UserRepo.find(value.to_i)
        else nil
        end
      end
    end

Now the delivery mechanism can be updated as well.

    class WebService < Sinatra::Application
      post "/todos" do
        form = TodoForm.new params['todo']
        use_case = CreateTodo.new form, current_user

        todo = use_case.run!

        content_type 'application/json'

        JSON.dump({
          todo: {
            id: todo.id,
            description: todo.description,
            due_date: todo.due_date.iso8601,
            assigned_to: todo.assigned_to.id
          }
        })
      end
    end

Now the test passes and it is time to move on to the non-happypath
scenarios.

    class WebServiceTest < MiniTest::Unit::TestCase
      def test_returns_json_when_the_todo_is_created
        # ...
      end

      def test_returns_a_400_when_todo_param_is_missing
        flunk
      end

      def test_returns_a_400_when_unknown_todo_params_are_given
        flunk
      end

      def test_returns_a_422_when_invalid_data_is_given
        flunk
      end
    end

It is easy to write the tests and much more interesting to make them
pass.

    def test_returns_a_400_when_todo_param_is_missing
      post "/todos"
      assert_equal 400, last_response.status
    end

    def test_returns_a_400_when_unknown_todo_params_are_given
      post "/todos", todo: { foo: 'bar' }
      assert_equal 400, last_response.status
    end

    def test_returns_a_422_when_invalid_data_is_given
      adam, peter = User.create('Adam'), User.create('peter')
      post "/todos", { todo: { foo: 'bar' } }, { 'current_user' => adam }
      assert_equal 422, last_response.status
    end

All the tests fail given the current code. Each tests because an error
is raised. The delivery mechanism can capture errors from the domain
classes and react accordingly. This strategy works for the last two.

    class WebService < Sinatra::Application
      error ValidationError do
        halt 422, { 'Content-Type' => 'application/json' }, JSON.dump({
          errors: env['sinatra.error']
        }
      end

      error UnknownField do
        halt 400, { 'Content-Type' => 'application/json' }, JSON.dump({
          errors: env['sinatra.error']
        }
      end
    end

The last two test pass. The first must be implemented inside the route
handler.

    class WebService < Sinatra::Application
      post "/todos" do
        todo_params = params.fetch 'todo' do
          halt 400
        end
        form = TodoForm.new todo_params

        # existing code
      end
    end

Now all the tests pass and the delivery mechanism implements all the
required functionality. Unfortunately there are a few things left to
be desired. It does not scale to generate JSON inside the route
handlers. In there real world there would be classes for this. This is
outside the example's scope, but is something to bear in mind. The
first test's implementation could be extracted into a helper. It does
not make sense to write that code in every single route handler. JSON
generation should also be generated using the `sinatra-contrib` gem.
The application does not parse JSON bodies out of the box. There is a
middleware in `sinatra-contrib` for that. This example presents a
barebones implemenation as a working example.

------------------------------------

## Choosing Libraries

So far this paper has espoused boundaries and proper responsibility
separation. Design patterns are used to arrange code the best way. The
example does not any gems (besides Sinatra). This is an explicit
choice. The technical examples shows it is possible to write
applications without using any frameworks. Domain objects are plain
old ruby objects. Functionality is added by writing basic Ruby code.

This works fine in the small but does not scale up. Every real world 
programmer uses libraries to multiply their productivity. The best
libraries solve common problems in reusable ways. They are better than
what one programmer could accomplish and have been tested in many
contexts by many different programmers. All libraries are not created
equally. Some are miles ahead of others in their structure and
resusability.

The Ruby ecosystem presents a unique challenge. Rubygems.org hosts 
65,667 different gems. It is extremely difficult to separate the wheat
from the chaffe. There are hundreds of different gems for the same use
case. Each has their own versinoning scheme, maintenance level, and of
course functionality. More importantly, deciding what gems an
application uses has a very strong impact on its long term
maintainbility. Some gems have 5 or 6 dependencies, then each may have
its own multiple dependencies. It is easy to see how projects devolve
into gem dependency hell.

Each library must be heavily scrtunizied before use in an application.
The upcoming section presents a curated set of gems that cover most
responsibilities in a modern application. They've been evaluated on
their dependencies, functionality, respect for boundaries, and design.
This is the ideal stack in terms of extesnsiblity, testing, and long
term maintainability. There is a gem (or multiple gems) that make
implementing each layer each allowing focus on the task at hand and
not common problems.

The example covers these basic layers: persistance, input
sanitization, HTTP access, and testing. Real application do much more
than this. A gem is presented for each core responsibility and other
common use cases.

### Persistence & Repository Implementation

The ecosystem is weak here but developing strongly. Rails &
ActiveRecord have dominated for so long that the community has
(unfortuantely) focused around expanding their functionality. Luckily
this is changing. The ROM (Ruby Object Mapper) is the most promising
gem in the community today. ROM is formally DataMapper 2. DataMapper
one was a quasi data mapper. ROM is a full object mapper. There is a
complete separation between objects, persisted implementation, and
access. Unfortunately ROM is not ready for production use.  There are
a few other choices until then. The repository pattern itself is
simple to implement. The adapter can be written using any of the
native interface gems. Sequel for working with an RDMS. Its query
capabilities are the best Ruby as to offer. It does not hide SQL which
is especially important since adatpers must be as close to the metal
as possible. Sequel has adapters for all major databases as well.
Redis, Moped, and others can used if a RDMS is not an requirement.

Unforunately the ecosystem does not have a complete solution to the
persistance story presented in this paper. The ecocystem does provide
the primitives needed to write adapters. This will change as ROM
matures.

### Input Collection & Sanitization

This area is the border between the application and the horrible world
outside. The solution must be robust, battled tested, and easy to
extend to handle weird input scenarios. Virtus embodies all these
qualities. `TodoForm`'s implementation could be replaced completely
by Virtus.

Virtus is an extraction of the ROM property interface. It provides a
simple and elegant for describing what attributes a class should have.
It also provides conversions and coericions (such as strings to
numbers, or strings to a time).  Writer methods can be redefined for
application specific functionality (using an the repo to look up an
object by id)i. It gained popularity as a “Form Object” inside rails
applications because it is so useful for parsing input. Virtus also
encourage reusability. Classes include a module.  Virtus can also
build multiple modules for maximum composability.

### Serialization

Generating machine readable formats is becoming more important than
ever. This is why their implemenation must be designed with object
orientated principles and testability in mind. There are generally
two different approaches but work the same under the hood. Some code
builds up a hash instance which can be serialized into any JSON, XML,
YAML, or MessagePack. The public interface differinates them.

JBuilder uses a builder style DSL. It uses a builder and template
language like concepts to build JSON objects. ActiveModel::Serializers
uses standard ruby classes that generate serializable hashes.
ActiveModel::Serializable is better because it has a simple public
interface that makes testing easier. It also makes generating complex
object graphs easy.

There are a few other things that make ActiveModel::Serializers a
better choice. ActiveModel::Serializers was designed around JSON API.
JSON API is a standard for communicating objects and their
relationships over HTTP. This makes it easier to write API consumers
because their are standards and conventions. The same cannot be said
about JBuilder.

ActiveModel::Serializers also provides a clear use story. There will
be a time when an application needs to serialize an object from a
"random" place. Think a background job that sends changes using server
sent events. In this case simply instantiate the serializer with the
serializable object and call `serializable_hash`. The same interface
is used when writing tests.

Each serializer is a subclass of `ActiveModel::Serializer`. It
declares which keys and associations should be included in the final
output. Jbuilder feels like a very complicated template language where
JSON responses are treated as views instead of first class objects.

ActiveModel::Serializers is the superior choice for serialization
responsibilities.

### Making HTTP Requests

Working with HTTP is a modern application requirement. Application
usually interact with 2 or 3 API’s, some much more. Choosing a good HTTP
library impacts the application long term. The Ruby ecosystem is
overwhelming web centered so naturally there are a cornicophia of
choices.

Ruby bundles an HTTP client in the standard library. Unfortunately it
less than a joy to use. The interface complicated and inconsistent.
It is a struggle to make requests beyond simple GET and
POST’s. Setting body content and content type is convoluted. It does
not excel at posting JSON documents. Configuring HTTP auth is
different in every single use case. HTTPS must be configured
explicitly as well. The library does not work with URL strings.
Instead you must create a URI and pass that around—sometimes. The API
is consistent here. Simple GET requests can be made with a String but
pretty much everything else requires a URI. It is considered one of
the worst APIs for these reasons.

Net::HTTP falls short at the “just make this request with this data”
use case. If you only need simple requests it may not be worth it
bring in another dependency. However most applications interacting
with HTTP must work with multiple server and their semantics.
Net::HTTP does not make this easy.

There are a bunch of gems that attempt to solve Net::HTTP's problems.
There are HTTParty, RESTClient, Tyepheous, and Excon to name a few.
They are all better than Net::HTTP and tailored to specific use cases.
HTTParty is quick and dirty. It parses JSON or XML responses into
OpenStruct like objects. It is not bound a particular URL structure
either. It excels at the “Just make this request use case”.
RESTClient is undoubtedly optimized towards RESTful interfaces. It has
the general functionality as well. RESTClient and HTTParty both use
class methods (RESTClient.post) which does not encourage reuse. Excon
is a more advanced general client with similar functionality. It is
not worth delving in these projects in depth because there is another
project that makes them irrelevant.

Faraday stands above the rest. It has a friendly interface and is easy
to extend and reuse. It uses the builder pattern to construct clients
and the adapter pattern to make requests. Faraday is the HTTP library
to rule them all. Faraday can use different HTTP clients making it
very portable. Faraday works Net::HTTP out of the box. All
Net::HTTP’s ugliness is hidden and does not require an additional
dependencies.

The builder pattern makes customizing HTTP clients easy.
This is important when working with HTTP API because each has unique
semantics. A FooBarClient can be created with middleware to add
authorization headers or parse response bodies. Clients can also be
created for one off requests. Faraday excels at the “just make this
request” use case. The interface is familiar to `Rack::Test` where you
can specify urls, params, and headers. The `faraday_middleware` project
provides middleware for common use cases. Faraday also works perfectly
with WebMock which makes testing HTTP requests a breeze. Faraday also
has a test adapter which can provide response stubs as well.

Faraday embodies all the qualities of good design. It its easy to
customize and is not implementation specific.

### Caching

A good architecture makes it easy to defer important decisions. This
means creating boundaries and sticking to interfaces and not specific
implementations. What does that mean? Assume the application needs
Memcached. It is not smart to access Memcached directly. This will
pepper the codebase with calls to an external service as well as
couple it a specific implementation.

Instead create a boundary via a public interface. Then the
production implementation descision can be deferred and the
implementation can be swapped in different use cases. This is the
adapter pattern.

Rails uses ActiveSupport::Cache but does not leverage it effectively.
Rails has a global enable caching flag. This is dangerous because it
creates a separate code path when enabled. Objects that implement the
cache interface will not be tested correctly. This it the wrong
solution. The correct solution is to always "enable" caching and swap
implementation for a null object one.

ActiveSupport::Cache provides two key implementations: InMemoryStore
and NullStore. This means you can develop and test under sane
conditions. ActiveSupport::Cache also provides a very friendly
interface. It easy to get and set values, even though fetch is the
most common. It also supports a TTL option in all stores. The library
also emits performance metrics so can track cache timings and hit
rate. Logging is configurable as well. There are implementations for
memcached and redis. ActiveSupport::Cache should cover all the bases.

### Performance Metrics

Application performance is always important. Users love fast
applications. It is the developer's responsibility to keep them that
way. They need data to do that. There are a few ways to go about
this. NewRelic is probably the first thing that comes to mind. StatsD,
Metriks, and ActiveSupport::Notifications are other choices. 

NewRelic is OK at what it does. However is not clear how to instrument
custom code. The data is also bound to NewRelic. It is not easy to
handle performance data in a new way. NewRelic is a big library with a
performance fooprint. Some projects have stopped using NewRelic
because of this. It also tried to do many things; the jack of all
trades, master of none.

The other choices are better but ultimate fall short of StatsD. Statsd
is the best choice because it provides a straight forward interface
with understandable primitives. Performance metrics are sent to a
statsd process over UDP. The application knows the "what" part and the
server knows "how". The statsd process can log measurements to
multiple sources through the adapter pattern. Statsd supports graphite
out of the box. Graphite is extremely powerful since data can be
composed in an imagineable way. There is a Librato adapter as well.

Stats is perferable choice because rate per secon and totals can be
added with a single line of code. It also provides a clear boundary
between data collection and handling. It provides a solid base for
projects like Harness to build on in an extensible and maintinable
way.

### Views & Templates

The view layer is a potential minefield in every delivery mechanism.
It is easy for logic to enter templates. Over time templates become
the biggest technical debt source in the application. This must be
actively fought against. Logic enters templates faster than any other
place in an application. This is usually because it’s so easy. Time to
put a stop to that. 

Logicless views are the **only** correct way to handle templates. A
logicless template language forces you create objects that provide
data. It is impossible for application specific logic to enter
templates. There are so many templating languages and projects
targeting this space. Luckily one stands head and shoulders above the
rest.

Mustache is the tool of choice. It is completely logicless. It has
looping and if support which is everything you need. It does not have
helpers. This is a good thing. It also provides a secondary benefit.
There are implementations in many languages, most importantly
JavaScript. It is possible share templates on the client and
server. It is possible to render HTML on the server then use a
JavaScript framework in the client--just need to provide the view
model.

What is a view model and what do I use it for? This term is synonymous
with “presenter.” There are tons of presenter libraries out there.
There are not needed. Most are proxies. This is a bad idea because
they expose the whole object but in a decorated state. The view model
should be exactly what the template needs—nothing more and nothing
else. It should be impossible for the template to access anything
other an public methods on the view model.

If this structure scares you, check out Handlebars. It allows helpers
and a little logic in templates. There is always a compromise.

### HTTP Delivery Mechanism

Sinatra wins hands down. Sinatra is one the best Ruby gems in the
entire ecosystem. It is well maintained and exemplifies a good
project. Sinatra is Rack at its heart. Rack is simple and has a
powerful middleware abstraction. It is surprising how much a few
middleware can accomplish.

Sinatra is the perfect HTTP delivery mechanism because it handles all
the protocol stuff and provides a simple API for declaring request and
response handling. The bulk of Sinatra’s code fits into a single
file. It has session support, caching, template rendering that really
make it a joy to work with. The ‘sinatra-contrib’ gem includes plenty
of helpful middleware as well. Rack, Sinatra, and sinatra\_contrib
provide everything needed to deliver an application over HTTP. Sinatra
is not a framework. That makes it more powerful than any framework
since the developer is in control.

Sinatra is very modular. Larger web services can be composed of
multiple Sinatra applications. Sinatra applications can also be used
as middleware in Rack or other Sinatra applications.
example from my last project.

Testing Sinatra applications is easy as well. Rack::Test makes testing
a breeze. Capybara works as well. Tests happen fast. There is no boot
time either since it has few dependenices. It only has 3 dependencies:
rack, rack-protection, and tilt (for rendering templates of every
nature).

### Test Framework

The Ruby community focused heavily on tests. Naturally there are many
testing libraries and helper projects. Luckily the best option is part
of the standard library.

MiniTest is the best test framework for a few reasons. Firstly it is
part of the standard library. There are no dependencies. The
implementation is readable and one sitting. It also includes a
parrallel test runner. MiniTest also includes the RSpec style syntax
if prefered. MiniTest also makes it easy to define shared tests and
custom assertions.

There are more things to a test suite besides the framework. Use mocha
for moching/stubbing. Use webmock for faking HTTP. Use DatabaseCleaner
to empty out data persisted in tests (for when you need it).
Rack::Test for testing the HTTP delivery mechanism. Capybara +
poltergeist if you need to test JavaScript. Each of these integrate
very nicely with MiniTest.

### The Ideal Stack

All of these libraries represent the ideal stack of Ruby applications.
Each library has minimal dependencies and exists to fulfull a single
responsiblity. Using them in concert makes developing and testing
applications easy. Using these libraries is a commitment to technical
investment.

The introduction focused on technical debt vs technical
investment. Applications acquire a large amount of technical debt
in the beginning. This is very dangerous debt because it will live on
forever. The first choices are the most important. They must be
thought out and encourage a good architecture. Examining why these
these choices and qualities are important is only possible by
understanding the past.

*I think this transition can be stronger*

## The Current Approach

It goes without saying that using Rails is the most popular way to
build Ruby applications. Rails exposed the world to Ruby. Since many
people learned Ruby through Rails, the Rails philosophy is deeply
ingrained into many Ruby developer's experiences and practices.

Rails was a revolutionary framework when it was released to the world.
It solved the problem of creating basic database backed CRUD
applications. Until then, these applications were tedious to write and
done in PHP. Rails exploded onto the scene with metaprogramming, code
generators, and an MVC stack. It was possible to generate a simple
CRUD app in minutes. It was revolutionary.

Over time Rails applications became older. Unfortunately most
applications became mired in technical debt. This was a direct effect
of using Rails in its generally encouraged way. The Ruby on Rails
framework does nothing to encourage proper design. It is not a good
MVC implementation. It does not respect the boundary between domain
objects and persitance. It does not enforce logic less views, in fact
it does the opposite. Large Rails applications usually became large
balls of mud with a dizzing number of gem dependencies.

The underlying problem is that applications where built *in* Rails
instead of *using* Rails. Each part of the MVC architecture encouraged
coupling and technical debt. It is important to understand Rails and
its implementations encourage technical debt so the same mistakes are
not made.

*need some transionary sentences/paragraph to connect to the breakdown
sections*

### ActiveRecord

ActiveRecord was Rail's biggest selling point in the beginning. It was
the first ORM that many web programmers interacted with. It was made
going from database schema to Ruby objects extremely fast and easy.
In this sense it is an excellent implementation of the ActiveRecord
pattern.

Unfortunately using the active record pattern as the sole data access
pattern in an application is a very data decision. The active record
pattern is the exact opposite of the more abstract data access and
persistence patterns. The active record patterns means the model is
the database. This flips the Repoistory pattern on its head. The
repository pattern provides access to domain objects and hides that
underlying implementation.

Active record based applications usually see database semantics creep
into all parts of the application. It is not uncommon to have
random objects making where clauses and knowing about table structure.
This is a direct effect of having entire query API public. What benefit
does pushing the database into all layers provide? It actually
provides negative value. It adds coupling, makes applications more
brittle and more difficult to change.

Since ActiveRecord models are database rows it is impossible to run
tests without the database. This creates slow tests and is directly
opposed to the fast feedback cycle TDD requires. There have been
attempts to mock ActiveRecord's database interactions to varying
success.  If a repository or data mapper was used the boundary could
be leveraged.

ActiveRecord will cause serious problems when the application reaches
a certain size. Its use must be highly regulated otherwise it will
infect everything. Rails encourages developers to think in database
tables and not in domain objects. This is a fundamentally bad
decision. Good arthictures make defering decisions possible. Storage
and persistance is a very important decision and should be made once
all objects and realtionships are known. Rails forces you to make this
decision in the beginning and live with it for the rest of the
application. This is the opposite of good design.

There are numerous other flaws. ActiveRecord callbacks are the easily
abused. The "fat model, skinny controller" movement has been going for
a long time. The logic is generally sound. It is correct that
controllers should not have so much logic. They are supposed to manage
the UI in MVC (remember MVC was originally designed for desktop
applications). In practice the models are ActiveRecord objects. They
usually expand to contain use case specific information. This is where
callbacks come in.

Sending a notification is a good example. How many applications
contain an `after_save` callback to send an email? How about a
callback to send the model to another data store (example: Elastic
Search)? Why is such behavior encouraged? Gems piggy back on the
ActiveRecord callbacks to add their own logic. Model class become
behavior junk drawers. Callbacks cause so much pain in large
applications. How do you tests callbacks? How can I disable this
callback in this context? These are two common questions. The answer
is: do not use callbacks. They encourage bad design. Their
implementation is shoddy at best. They are entirely more trouble than
they are worth.

ActiveRecord::Observer is a callback on steroids. It is a global
object that listens for model callbacks. Rails automatically
instantiates observer instances and connects them to ActiveRecord
instances. Every ActiveRecord callback is exposed to the observer.
This is not a good idea because the model itself cannot control which
events other objects can listen on. Observers have all the same
problems callbacks do. Except they are worse. Observers exist in the
global state. They are permantantly attach to model instances. How
many tests have failed because an observer was attached?  Observers
should not be attached globally. Rail's observer implementation
relies on global state which is arguably the worst thing in a program.

ActiveRecord instances are junk drawers. They collect methods for use
in other layers. `ActiveModel::Naming` contains all sorts of methods
that are not used by the model itself. They are primarily used in
controllers to generate URLs and for generating HTML forms. There is
even `partial_path` on the model. It is for automatic partial lookup.
The number of public instance methods on ActiveRecord::Base is
astonishing. ActiveRecord::Base instances do not follow the single
responsibility principle at all. They implement concerns for all
layers leading to coupling and leaky abstractions.

Nested attributes if a famous leaky abstraction and cross cutting
concern. This particular issue has caused strife in the community.
`accepts_nested_attributes_for` is for creating complex objects. A
Customer can `accept_nested_attributes_for` its associated Addresses.
An `address_attributes=` method is defined. It takes an array of
hashes instances. The hash may contain a magic `_delete` key indicating that
the given record should be removed from the collection. If an `id` key
is present, it is treated as an update or wise a new instance is
created. There are many things happening in these methods.
`accepts_nested_attributes_for` addresses a view problem. The problem
is: how to present an HTML form that represents a hierarchy of Ruby
objects? This one such way. Form objects are a better solution. The
form object knows how to instantiate the objects. Then passes along
domain objects to the model. `accepts_nested_attributes` is another
violation of the single responsibility principle. This one is
especially haenous because it clearly illustrates the coupling between
view content and database structure.

Mass assignment is another famous leaky abstraction. This has
partially been addressed in Rails 4, but is still an awkward solution.
Mass assignment protection was a solution to ActiveRecord's encouraged
use case. An HTML form is generated.  The controller takes the
gigantic params hash and simply dumps it onto the model. The model
dutifully sets its values from keys and values in the hash. Then
changes are written to the database. This approach is perfect for
generated CRUD applications. Eventually there is some sort of access
controlled information that should not be access through forms.
Massignment allows to whitelist or blacklist which attributes must be
set expliclity. This prevents people from crafting forms with
`admin=true` and posting them. Unfortunately this behavior was
disabled by default leaving every application insecure by default. It
took a very high profile incident to get the core team's attention on
this issue.

Github suffered a major security breach related to SSH keys.  *Igor
Hakmovkov (sp)* was able to exploit the rails organization and commit
directly to the master branch. He crafted a custom form including his
SSH key inside a nested attributes hash. The ssh keys association was
not protected by mass assignment and his ssh key was connected to
another account. This gave him full control of the entire repo. He
exclaimed his success with a famous commit stating: "look I can commit
to master."

This situation could have been completely avoided by using strong
boundary principles. Fortunately Rails has changed this behavior in
Rails 4 by requiring controllers to sanitize inputs. This is a good
change security wise, but why is a model enforcing security concerns?
ActiveRecord does not respect boundaries as usual.

Unfortunately the problems with mass assignment do not end there. Mass
assignment can also be made state aware. Here is an example. An admin
can set the permissions, but a normal user cannot. The context can be
passed with assignment satisfying this use case. These things do not
belong on a database backed object. They belong in policy objects or
in the use case. It is astounding these things were part of the core and
their use was encouraged up until recently.

There is one last example. JSON generation has become an important
responsibility. ActiveRecord implements the `to_json` method.
`to_json` is easily abused like all parts of Rails. `to_json` exposes
all data by default. When this is not enough there is a grab bag
option hash. The grab bag options are there to remove sensitive bits
or include methods and associations. The options hash can be nested to
pass options down to other object's `to_json` method. This is bad
practice. 

Machine readable data should be treated just like user
facing views. There should be a model and a template. Template is
loosely defined in this case. Jbuilder uses templates.
ActiveModel::Serializers uses an object that knows how to generate a
serializable object. Both are superior to calling `to_json`.
This is another example of ActiveRecord not respecting the
single responsibility principle and how it is a junk drawer that
encourages technical debt.

Most of ActiveRecord's problems are because it is the active record
pattern. The "junk drawer" aspect comes form a bad MVC implementation.
The fact is that ActiveRecord does not respect key architectural
boundaries. ActiveRecord's flaws can be controlled with cautious use,
but it has to be quarantined from the very start. Fast tests are
impossible with ActiveRecord because the database is the model and the
model is the database. ActiveRecord's abstractions will leak into more
parts of the application and make it difficult to maintain over time.
It is fast in the beginning but the pattern completely falls over once
complexity reaches a certain level. ActiveRecord simply does not
encourage maintainablity.

### ActionView

ActionView is another component optimized for quick ramp up times. Set
instance variables in the controller, call some helpers inside the
template and things start to happen. The controller adds more instance
variables and templates become more complex. Logic eventually enters
the templates. Helpers are added to manipulate instance variables. ERB
templates make query calls on ActiveRecord objects. Eventually the
application itself spills into templates and things become an
untenable mess. ActionView gives provides developers just enough hope
to hang themselves. Complexity and leaky abstractions must be
quarantined and managed with extreme prejudice. Developer's usually do
not have the stomach for this.

ActionView suffers from two fundamental problems. ERB is the first.
ERB stands for Embedded RuBy. It is possible to write entire
application inside an ERB template. This is a major flaw. It can be
avoid, but it is not in 99% of cases. If you cannot put logic into the
template it must go somewhere else. This is correct way to do things.
The templates must be the stupidest part of the entire application.
There is a serious problem if they are not. Using a logic less
language (such as Mustache) forces a structured approach to the
presentation layer. It forces a boundary and single handily eliminates
all common problems inside Rails templates.

The second problem exacerbates the first. Templates are executed in
the controller's action's binding. This means they have access to the
local and global scope. Want to call out to another class, that is
possible. Templates also inherit a large scope including
ActionView::Helpers.

Helpers are used to offload logic from the template into a Ruby
module. This is not enough. All helper modules are available globally,
you cannot decide which templates use which helper modules.  This
encourages a mishmash of methods where it is hard to locate where
things actually happen and what methods are available. Eventually
helpers depend on instance variables set in other places and things
become an untenable mess.

ActionView and ERB is a dangerous combination. It is almost designed to
acquire technical debt. A View Model and logic less template setup
couuld and has been implemented for ActionView. However it is easier to
just forgo the entire thing if must change fundamentally.
Architectures and libraries that encourage technical debt should be
avoided. Unforuntely the useless of some of the helpers encourages
their use throught templates. This is a testament to their usefullness
but not their implementation. The helpers are why programmers love
ActionView and are afraid to give it up.

### ActionController

ActionController is the best part of Rails. It does a wonderful job of
handling incoming HTTP requests and returning HTTP responses. It
handles responding in multiple formats nicely and the routing works
very well. It is easy to do protocol level things as well. Controllers
can set HTTP cache headers and handle stale responses with ease.
There would be no problem if applications only used the HTTP specific
functionality. The problems come from what happens inside the methods.

The controller's job is to make things happen. There are two schools
of thought: fat model/skinny controller or fat controller/dumb model.
The former leads to the problems described in the ActiveRecord
section. The latter means putting application specific logic inside
the controller, thus coupling your application to an HTTP delivery
mechanism violating a fundamental boundary. Fat model/skinny
controller usually leads to brittle tests with a ton of mocking and
stubbing. Tests usually end up matching the code line by line and
provide no value. Putting logic into the controllers means business
logic tests must go through HTTP. Either way the application is bound
to HTTP and the framework becomes the appliction and delivery
mechanism.

Rails 4 introduced strong paramters. Strong paramters is the solution
to mass assignment problem. It is a step in the right direction
because the concern is removed form the model and pushed into the
context where input is used. However this is not enough because it
only ensures which keys are allowed and not their values. The model
must do parsing with the likes of `accepts_nested_attributes_for`.
This encourages logic in two different places: the model and the
controller. This logic belongs in a proper boundary object like a form
object.

These are not problems with ActionController itself. It has everything
to do with how it is used.

### Rails as a Framework

All the core component's problems are connected to Rail's
implementation of MVC. The models are ActiveRecord instances.
Controllers dump everything off to the model, then the controller's
scope is used to render an ERB template. ActiveRecord's semantics
propagate through all layers. Views start taking to models,
controllers render views that talk to models or interact with the
global scope. Everything is talking to everything and there are no
boundaries.

Rail's design does not encourage technical investment. It
encourages technical debt and in most cases actually encourages it.
This is because Rails is entirely focused on the early stages of the
application. It is opitimized for fast development in the beginning.
Overtime the productivity falls because there is nothing left to
leverage.

ActiveRecord causes most of Rail's problems. It causes the most
problems because it violates the most boundaries. The separation
between domain objects and persistence is arguably the most important
boundary. This is at the root of many other problems. Looking through
all the core components reveals consistent boundary violations. This
is why boundaries are so important. They encourage the proper
responsibility separation. This is why the paper focuses on strong
separation between layers and object responsibilities. Each boundary
is there to remove pain points that common in most current
applications.

----------------

## Case Study: RadiumCRM

RadiumCRM (henceforth known as Radium) chronicles the evolution of
most Rails applications. It started life being directly built in Rails
2, then as an API in Rails 3, then abondoning Rails in favor of
architecture in this paper. Radium is currently beta software. The
backend is written using Sinatra for HTTP and parts of the ideal stack
for everything else. Radium is unique because it is one first
applications to adopt Ember.js for a full and separate Javascript
frontend.

The business rules are quite complicated. There are roughly twenty
main models. Some have internal state machines. Models in different
states interact differently depending on their states. There are
complicated data access policies. Users can access content based on
ownership or social permissions. User's data is also imported from
various third party services and synced backed to one or multiple
third party services. The model count is not very high, but managing
domain object interacts is the most complicated part. This was the
driving force behind the architecture change.

The entire application existed as a single Rails application for
roughly two years. The test suite took around one hour and fourty five
minutes. The tests were this slow for a multitude of reasons. Firstly,
the majority of the tests used Cucumber with Capybara. Selenium was
used since that was the only viable option at the time. Secondly,
since most of application logic was coupled between Rails controllers
and models, the most important test had to go through the GUI.
Thirdly, it was impossible to run tests without a database since the
application was coupled to ActiveRecord. The test suite also dependend
on third party services like Microsoft Exchange to test syncing. All
these factors combined created a very slow (and somewhat finnicky)
test suite. This was the most visible pain point.

The view layer (and other user facing code) was responsible for most
of the application's complexity. The pages in the application
displayed too many things. Each page had multiple widgets each with
their own interactions. The user interface was updated with server
rendered JavaScript. This was before Backbone and other JavaScript
frameworks came onto the scene. Maintaining the JavaScript was
challenge enough. Maintaing the view templates was the most difficult
part. Naturally overtime the templates acquired logic and got to a
point where they were near impossible to change.

Rail's prescribed MVC excerbated the problem. The application followed
the fat model/skinny controller advice. The tetriary class advice
inhibited other emerging object roles. The application grew to contain
many

