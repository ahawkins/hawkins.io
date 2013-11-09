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
smart investments lead to long term success. Software engineering is
the same way.  Investments must be made in an application's
architecture to maximize its long term success, feature
deliverability, and scalability. It is time to apply the same long
term financial planning to software applications.

Technical debt is the cost of previous engineering decisions.
Implemenations can be quick and dirty way or executed to meet current
needs and also setup the next iteration.sThis illustrates the choice:
quick and messy, or slower and cleaner.sEvery programmer has made
this decision "oh, I'll just hack this in” then written FIXME directly
above it." Then probably thought to themselves how to implement it
correctly. Applications often collapse under their technical debt.
Applications become impossible to maintain. Iterations become longer,
deliverability estimates are incorrect, and developer happiness
plummets. In the worst case, starting over is the only way to repay
the debt.sThis is an unfortunate but avodiable situation. This
situation happens when engineering teams (for whatever reason) decide
to accumulate more technical debt. The decision usually comes from
business requirements and short delivery dates. Teams must actively
decide to pay back their debt in terms of technical investments.
Projects incur most technical debt in the early stages. This is the
most delicate time in an application's life time. Just like real life
childhood, the decisions (good, bad, and ugly) made in the formative
years have a strong lasting impact. The signs of excellent parenting
live on and people grow into well adjusted individuals. Horrible or
abusive parenting often leave scars for life which are difficult or
impossible to heal without serious effort. This paper is about making
technical investment in application architecture from t0 to raise a
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
created or modifies. Perhaps some external state is modified (like
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

## The Ideal Stack

This paper has espoused the correct arrangement of objects and their roles. Now
it’s time to look around the ecosystem and see which projects exemplify the
best traits. We need a delivery mechanism, a way to render to templates,
serialize objects, sanitize and format user input, persist data, query and
manage data access, send outgoing HTTP requests, handle caching, and
application level metrics. This covers a large swofft of responsibility. It
would be unwise to look to a single project to implement everything. Ruby’s
ecosystem’s provides many choices in all areas.

### Persistence & Repository Implementation

The ecosystem is weak here but developing strong. Rails & ActiveRecord have
dominated for so long that the community has primarily focused around that
implementation. Luckily this is changing. The ROM (Ruby Object Mapper) is the
most promising gem in the community today. ROM is formally DataMapper 2.
DataMapper one was a quasi data mapper. ROM is a full object mapper. There is a
complete separation between objects, persisted implementation, and access.
Unfortunately ROM is not ready for production use yet. I’m eagerly waiting for
when it is. There are a few other choices in the mean time. The repository
pattern is simple to implement. Then you must write your own adapter. I
recommend Sequel for working with an RDMS. It’s query capabilities are the best
Ruby as to offer. It does not hide SQL from you, which is something you want
when writing a repository adapter. It includes `Sequel::Model` if you want an
active record feel. It has adapters for all major SQL implementations as well. 

Final Recommendation: Wait for ROM. Implement the repository yourself. Use the
low level libraries (such as Sequel, MongoDB, Redis) to implement the adapter.

### Input Collection & Sanitization

It’s important that you get this right. That’s why it’s important you use
Virtus. Virtus is an extraction of the ROM property interface. It includes
coercion (strings to numbers). It provides a simple and elegant for describing
what attributes a class should have. You can refine writer methods to implement
application specific functionality (using an the repo to look up an object by
id) so working with the domain objects is trivial. It gained popularity as a
“Form Object” inside rails applications because it’s so useful for parsing
input. Virtus also encourage reusability. It’s a module so it can include it
any class. Subclassing is not an requirement.

Final Recommendation: Virtus

### Serialization

Generating machine readable formats is becoming more important than ever.
That’s why they must be OOP and easily testable. There are generally two
approaches in this area. Objects that know how to generate a serializable hash
or a builder object. The former makes more sense. Instantiate the object with
the attribute and ask for its serialized representation. This approach is also
more composeable. This makes object graph serialization easier. Graph
serialization can be a complicated problem. The problem stems from serializing
a root object then its specified associations and down the tree. It can be
recursive as well. ActiveModel::Serializers excels here because it was designed
for use with Ember Data. Ember Data is a data mapper for the Ember Javascript
framework. Ember Data makes working with RESTful JSON API’s easy by relying on
convention. You get a few correct conventions for free. All JSON objects have a
root. This makes its easier for clients to parse responses into objects. Here’s
an example. The JSON object has two root keys: “customers”, and “tasks”.
Consumers know that these keys map to corresponding domain objects and parse
accordingly. It’s also easier to add meta data to response because everything
is namespaced. ActiveModel::Serializers also has strong association
conventions. Associated objects can be sideloaded or embedded. Here’s an
another example with customers and tasks. The application may want to present a
customer with their tasks. The backend can sideload full objects. This means
the “tasks” key at the root contain’s a full JSON representation of each task.
Each customer object will include a `task_ids` key linking back to the object.
The library can generate IDs only if the full object is not needed. This cuts
down on response size. Associated objects can also be embedded directly.
Association handling can be configured with a global default then customized on
a case by case basis. ActiveModel::Serializers makes crafting JSON responses
easy. I haven’t seen a builder based library with this functionality.
ActiveModel::Serializers provides a solid base for Javascript applications or
simple API consumers. Insert note about libraries focused on both way
serialization instead of one way.

Final Recommendation: ActiveModel::Serializers

### Making HTTP Requests

Working with HTTP API’s is a modern application requirement. Application
usually interact with 2 or 3 API’s, some much more. Choosing a good HTTP
library will impacts the application long term. The Ruby ecosystem is
overwhelming me web centered so naturally there are a bajillion libraries.
Let’s look at the big players.

The standard library includes an HTTP client. It’s less than a joy to use. The
interface is the most complicated out of the group. It’s a struggle to make
requests beyond simple GET and POST’s. Setting body content and content type is
convoluted. It does not excel at posting JSON documents. Configuring HTTP auth
is different in every single use case. HTTPS must be configured explicitly as
well. The library does not work with URL strings. Instead you must create a URI
and pass that around—sometimes. The API is consistent here. Simple GET requests
can be made with a String but pretty much everything else requires a URI.
Net::HTTP falls short at the “just make this request with this data” use case.
If you only need simple requests it may not be worth it bring in a dependency.
However most applications interacting with HTTP API must work with semantic
different in each making it very difficult to use Net::HTTP. 

Then there are a bunch of libraries that function roughly the same way. There
is HTTParty, RESTClient, and Excon to name a few. They are all better than
Net::HTTP and tailored to specific use cases. HTTParty is quick and dirty. It
parses JSON responses into OpenStruct like objects. It’s not bound a particular
URL structure either. It excels at the “Just make this request use case”.
RESTClient is undoubtedly optimized towards RESTful interfaces. It has the
general functionality as well. RESTClient and HTTParty both use class methods
(RESTClient.post) which does not encourage reuse. Excon is a more advanced
general client with similar functionality.

Faraday stands above the rest. It has a friendly interface, uses the builder
pattern, and adapter pattern. Faraday is the HTTP library to rule them all.
Faraday can use different HTTP implementations making it very portable. Faraday
works Net::HTTP out of the box. This means hides all the Net::HTTP’s ugliness
and doesn’t require another dependency. The builder pattern makes customizing
HTTP clients easy. This important when working with HTTP API because they all
their own semantics. A FooBarClient can be created with middleware to add
authorization headers or parse response bodies. Clients can also be created for
one off requests. Faraday excels at the “just make this request” use case. The
interface is familiar to `Rack::Test` where you can specify urls, params, and
headers. The faraday_middleware projects solves a lot of common cases as well.
Faraday also works perfectly with WebMock which makes testing HTTP requests a
breeze. You cannot go wrong with Faraday.

Final Recommendation: Faraday

### Caching

A good architecture makes it easy to defer important decisions. This means
creating boundaries and sticking to interfaces and not specific
implementations. What does that mean? Assume the application need to Memcached.
It is incorrect to access Memcached directly. Instead access the cache which
uses a specific implementation. This is essentially the adapter pattern. The
adapter pattern makes it possible to use a real implementation in production
and another implementation in development or tests. This allows you defer
important decisions until you know them, but still design with caching
regardless of the final datastore. ActiveSupport::Cache follows these
principles. It’s a shame rails does not utilize them. Rails encourages a
separate code path (disable_caching = true) instead of using a null object when
a null implementation is bundled! This can create errors when in production
because there is no tests over how the cache serializes objects. This is why
ActiveSupport::Cache is such a joy to work with.

ActiveSupport::Cache provides two key implementations: InMemoryStore and
NullStore. This means you can develop and test under sane conditions.
ActiveSupport::Cache also provides a very friendly interface. It’s easy to get
and set values, even though fetch is all you need from my experience. It’s also
supports a TTL option in all stores. The library also emits performance metrics
so can track cache timings and hit rate. Logging is configurable as well. Dalli
is the best memcached driver. Dalli includes an ActiveSupport::Cache
implementation as well. 

Final Recommendation: ActiveSupport::Cache + Dalli

### Performance Metrics

Application performance is always important. User’s love fast applications.
It’s our responsibility to keep them that way. We need the data to do that.
There are a few ways to go about this. NewRelic is probably the first thing
that comes to mind. StatsD, Metriks, and ActiveSupport::Notifications are other
choices. NewRelic is OK at what it does. I think it’s too heavy. It’s unclear
how to instrument your own code without loading NewRelic in every environment.
This is not good design. ActiveSupport::Notifications works as well. It’s more
of a pubsub library than an instrumentation library. The events include timing
information so they can be connected to a tracking tool.

ActiveSupport::Notifications is slow though which is why I gave it up. Statsd
and Metriks are similar. Metricks runs inside the ruby process aggregating
stats. It has counters, gauges, and meters. Statsd is similar except it talks
to server over UDP. It provides counters, timers, and gauges. I’ve found StatsD
the most effective. StatsD is battled tested. It integrates with graphite out
of the box. Say what you want about graphite’s GUI, but it really is a powerful
tool. If you don’t like Graphite that’s not a problem. There are plenty of
other backends for Statsd. There is a Librato if that’s your fancy. I’ve found
StatsD’s interface easy to use and understand. You get rates per second and
total volume out of the box. Most people only want these numbers anyway.

StatsD is easy to get started with. Unfortunately most people want to count
stats everywhere. This leads to a global StatsD object. This is bad practice.
Also why do you want to instrument in development and test environments? You
don’t. Instrumentation calls are not free either. Each call sends a UDP packet.
This can cause problems at scale. I created Harness to make using StatsD a
little nicer. It exposes the exact same interface with some tweaks. It uses a
null statsd object out of the box. Metrics are also reported in a separate
thread. This way your application thread does not pay any cost for performance
metrics. There are also Harness libraries for all popular gems such as sidekiq,
sequel, redis, and memcached. Harness provides everything needed in an
obtrusive way.

Final Recommendation: I’m tooting my own horn and going with Harness. More about Harness here.

### Views & Templates

Using a logicless template language is the only correct way to do templates. A
logicless template language forces you create objects that provide data. It is
impossible for application specific logic to enter templates. Logic enters
templates faster than any other place in an application. This is usually
because it’s so easy. Time to put a stop to that. There are so many templating
languages and projects targeting this space. Luckily you only need one.
Mustache is the best option here. It is completely logicless. It has looping
and if support which is everything you need. It does not have helpers. This is
a good thing. It also provides a secondary benefit. There are implementations
in many languages most importantly JavaScript. This means you can share
templates on the client and server. It is possible to render HTML on the server
then use a JavaScript framework in the client. You just need to provide the
view model.

What is a view model and what do I use it for? This term is synonymous with
“presenter.” There are tons of presenter libraries out there. You don’t need
any of them. I haven’t seen any that provide any real value. Most are simple
proxies. This is a bad idea because they expose the whole object but in a
decorated state. The view model should be exactly what the template
needs—nothing more and nothing else. If you only need a proxy than use the
standard library. There’s no good reason to pull in another dependency. A
simple class with defined methods is everything you need.

If this structure scares you, check out Handlebars. It allows helpers and a
little logic in templates. There is always a compromise.

Final Recommendation: Mustache + PORO (Plain Old Ruby Objects) for view models.

### HTTP Delivery Mechanism

Sinatra wins hands down. Sinatra is one of my favorite Ruby projects. It’s well
maintained and exemplifies a good project. I love Sinatra because it is Rack at
heart. Rack is simple and has a powerful middleware abstraction. It is
surprising how much you can build with a few middlewares and a rack server.
Sinatra is the perfect HTTP delivery mechanism because it handles all the
protocol stuff and gives you just enough power to handle the other things. The
bulk of Sinatra’s code fits into a single file. It has session support,
caching, template rendering that really make it a joy to work with. The
‘sinatra-contrib’ gem includes plenty of helpful middleware as well. Rack,
Sinatra, and sinatra_contrib give you everything you need to deliver an
application over HTTP. Sinatra is not a framework and that’s awesome. It gives
you the tools you need to solve your problems and stays out of the way.

Sinatra is very modular. You can compose larger web services out of multiple
sinatra applications. Sinatra applications can also be used as middleware in
Rack or other   sinatra applications. Here’s an example from my last project.
The API part was stateless. Sessions has been disabled and I didn’t want to
pollute the app with user authentication and signup. I created a SignUpService,
enabled sessions and installed omniauth. Then I mounted that use Rack::URLMap
in config.ru. I could continue to test the applications independently but serve
them together.

Testing Sinatra applications is easy as well. Rack::Test makes testing a
breeze. Capybara works as well. Tests happen fast. There is no start up time
with Sinatra because it’s so lean. It only has 3 dependencies: rack,
rack-protection, and tilt (for rendering templates of every nature).

Final Recommendation: Sinatra without a doubt.

### Test Framework

Time for a holy war. The Ruby community is divided into RSpec users and
MiniTest/TestUnit. There is the whole BDD vs TDD thing. This really is all
hogwash. It does not make a difference at the end of the day. It comes down to
personal preference at the end of the day. I used to be an avid RSpec user.
Then I tried MIniTest. Now I use MiniTest for a few reasons. The main reason is
that it’s in the standard library. Don’t bring a dependency into a project if
there is a good reason. MiniTest is wonderful and makes writing tests easy.
MiniTest is small and fast. You can read the entire code in one sitting. You
cannot do that with RSpec. It’s very difficult to define custom matchers in
RSpec. I’ve written a few and can never remember it. Want to write your own
assertions in using MIniTest, simply define a method! Every refactoring and
code structure technique for Ruby classes applies to test classes. MiniTest
also provides rspec like syntax with “describe” and “it” as well. MiniTest can
also run tests in parallel out the box. Simply require ‘minitest/hell’. 

There are more things to a test suite besides the framework. Use mocha for
moching/stubbing. Use webmock for faking HTTP. Use DatabaseCleaner to empty out
data persisted in tests (for when you need it). Rack::Test for testing the HTTP
delivery mechanism. Capybara + poltergeist if you need to test JavaScript.

Final Recommendation: MiniTest. Bow before MiniTest.

--------------------------------------------

## Problems with Rails

This paper's introduction focused on technical debt vs technical
investment. Applications may acquire a large amount of technical debt
in the beginning. This is very dangerous debt because it will live on
forever. The first choices are the most important. They must be though
out and encourage a good architecture. If you think starting an
application means running `rails new` then you've already lost the
game.

Rails is a web application framework. It's been around for almost 10
years now. It came around to make creating a certain kind of
applications insanely fast. Most applications were more or less CRUD
apps for managing database tables. The ActiveRecord pattern made sense
here. Scaffolding was perfect because that's what we wanted in most
cases. Rails was created to optimize this specific use case.
Applications became more complex. The JSON API arose. Now it's common
to have a backend in insert language here then a pile of JS code
creating the user interface. Rails best practices no longer scale up.
Most Rails applications turn into gigantic balls of mud because
coupling is encouraged. Don't think for a second Rails style MVC means
decoupled. Rails itself does not respect the described boundary
principles. In fact it does not encourage boundaries at all. This
section is a technical critique of each core component and how it's
encouraged use is detrimental in every use case and how you're
encouraged to build an app in Rails and not on top of it.

### ActiveRecord

ActiveRecord was Rail's biggest selling point in the beginning. It was
made going from schema to Ruby objects extremely fast and easy.
Overall it's a good implementation of the ActiveRecord pattern. Most
of ActiveRecord's problem come from the fact that it is the
ActiveRecord pattern. The ActiveRecord pattern is the exact opposite
of the more abstract data access and persistence patterns. The active
record patterns means the model is the database. This flips the
Repoistory pattern on it's head. The repository pattern provides
access to domain objects and hides that underlying implementation.
Extensive active record use usually means the database semantics
propagate through the entire application. It's not uncommon to have
random objects making where clauses and knowing about table structure.
This is an unfortunate side effect from the entire query api being
public. How many people have seen controllers constructing gigantic
where or query clauses? I ask why is that even possible? What benefit
does pushing the database into all layers provide? It does not provide
any long term value. It adds coupling and makes change more brittle.
Since ActiveRecord models are database rows it's impossible to run
tests without the database. There have been attempts to mock
ActiveRecord's db interactions to varying success. These efforts arise
from testing being too slow (because every thing hits the database).
If a repository or data mapper was used the boundary could be
leveraged. ActiveRecord will come back to bite you when your
application reaches a certain size. It's use must be highly regulated
in applications otherwise it will infect everything. Rails encourages
you to think in database tables and not in domain objects. This is a
fundamentally bad decision for people interested in technical
investment and not technical debt. 

There are numerous other flaws as well. ActiveRecord callbacks are the
most abused thing in Rails applications. The "fat model, skinny
controller" movement has been going for a long time. The logic is
generally sound. It is correct that controller's should not have so
much logic. They are supposed to manage the UI in MVC (remember MVC
was originally designed for desktop applications). In practice the
models are ActiveRecord objects. They usually expand to contain use
case specific information. Sending a notification is a good example.
How many applications contain an `after_save` callback to send an
email?  How about a callback to send the model to another data store
(example: Elastic Search)? Why is such behavior encouraged? Gems piggy
back on the ActiveRecord callbacks to add their own logic. This is not
the gem's fault. This is how you do things in the Rails world.
Callbacks cause so much pain in large apps. How do you tests
callbacks? How can I disable this callback in this context? These are
two common questions. The answer is: don't use callbacks. They
encourage bad design. Their implementation is shoddy at best. I
haven't seen a proper callback use case before. They are entirely more
trouble than they're worth. 

ActiveRecord::Observer is a callback on steroids. It's a global object
that listens for model callbacks. Rails automatically instantiates
observer instances and connects them to ActiveRecord instances. Every
ActiveRecord callback is exposed to the observer. This is not a good
idea because the model itself cannot control which events other
objects can listen on. Observers have all the same problems callbacks
do. The biggest is that observers are attached to all objects during
tests. How many tests have failed because an observer was attached?
The listeners should not be attached at all. The observer pattern is
wonderful. Rail's observer implementation relies on global state which
is arguably the worst thing you can do in a program.

ActiveRecord instances are a junk draw. They collect methods for use
in other layers. `ActiveModel::Naming` contains all sorts of methods
that are not used by the model itself. They are primarily used in
controllers to generate URLs and for generating HTML forms. There is
even `partial_path` on the model. This is use for automatic partial
lookup. The number of public instance methods on ActiveRecord::Base is
astonishing. ActiveRecord::Base instances do not follow the single
responsibility principle at all. They implement concerns for all
layers leading to coupling and leaky abstractions.

Nested attributes if a famous leaky abstraction and cross cutting
concern. This particular issue has caused strife in the community.
`accepts_nested_attributes` is for creating complex objects. A
Customer can `accept_nested_attributes_for` its associated Addresses.
An `address_attributes=` method is defined. It takes an array of Hash
instances. The hash may contain a magic `_delete` key indicating that
the given record should be removed from the collection. If an `id` key
is present, it’s treated as an update or wise a new instance is
created. There are many things happening in these methods.
`accepts_nested_attributes_for` addresses a view problem. The problem
is: how to present an HTML form that represents a hierarchy of Ruby
objects? This one such way. Form objects are a better solution. The
form object knows how to instantiate the objects. Then passes along
domain objects to the model. `accepts_nested_attributes` is another
example of ActiveRecord instance becoming a junk drawer.

Mass assignment exemplifies bad design. This has partially been
addressed in Rails 4, but is still an awkward solution. More on this
in the ActionController section. Mass assignment protection was
required by ActiveRecord’s encouraged use. An HTML form is generated.
The controller takes the gigantic params hash and simply dumps it onto
the model. The model dutifully sets it’s values from keys and values
in the hash. Then changes are written to the database. This approach
is problematic because all data was trusted. This was the default
behavior up until Rails 4. Here’s a high profile example that arguably
finally convinced the rails core team to address this serious design
issue. Github suffered a major security breach related to SSH keys.
Igor Hakmovkov was abel to exploit the rails organization and commit
directly to the master branch. He crafted a custom form including is
SSH key inside a nested attributes hash. The ssh keys association was
not protected by mass assignment and his ssh key was connected to
another account. This gave him full control of their entire repo.
Remember, this was the default behavior in rails for years. This
situation could’ve been completely avoided by using strong boundary
principles. ActiveRecord does not respect the boundaries between
different layers as usual. 

Unfortunately the problems with mass assignment don’t end there. Mass
assignment can also be made state aware. Here is an example. An admin
can set the permissions, but a normal user cannot. Now ActiveRecord
has crossed access control boundary! These things do not belong on a
database backed object. They belong in policy objects or in the use
case. It is astounded these thing were part of the core and their use
was encouraged up until recently.

There’s one last example. JSON generation has become an important
responsibility. Rails currently exposes two methods to make this
happen. JSON can be generated using JBuilder templates or by calling
`to_json` on pretty much anything. Jbuilder is an acceptable approach.
`to_json` is not. `to_json` is easily abused like all parts of Rails.
`to_json` takes a grab bag option hash. `to_json` exposes all data by
default. The grab bag options are there to remove sensitive bits or
include method and associations. The options hash can be nested to
pass options down to other objects ‘to_json` method. This is bad
practice. Machine readable data should be treated just like user
facing views. There should be a model and a template. Template is
loosely defined in this case. Jbuilder uses templates.
ActiveModel::Serializers uses an object that’s know how to generate a
serializable object. Both are superior to calling `to_json` whilly
nilly. This is another example of ActiveRecord not respecting the
single responsibility principle and how it’s a junk drawer that
encourages technical debt.

Most of ActiveRecord's problems are because it is the active record
pattern. The "junk drawer" aspect comes form a bad implementation of
MVC. Rails MVC implementation is another topic that's discussed later.
The fact is that ActiveRecord does not respect key architectural
boundaries. ActiveRecord's flaws can be controlled with cautious use,
but it has to be quarantined from the very start. You cannot have fast
tests with ActiveRecord because the database is the model and the
model is the database. ActiveRecord abstractions will leak into more
parts of the application and make it difficult to maintain over time.
It will be very fast in the beginning but the pattern completely falls
over once complexity reaches a certain level. The active record
pattern simply does not fit with architecture in this paper.

Did you also know ActiveRecord's error message translation is tied to i18n localizations? ---3---

### ActionView

ActionView is another component optimized for quick ramp up times. Set
instance variables in the controller, call some helpers inside the
template and things start to happen. More instance variables get added
to the controller and templates become more complex. Logic eventually
enters the templates. Helpers are added to manipulate instance
variables inside controllers. ERB templates make query calls on
ActiveRecord objects. Eventually the application spills into templates
and things become an untenable mess. ActionView gives you just enough
rope to hang yourself. Complexity and leaky abstractions must be
quarantined and managed with extreme prejudice. Developer's usually
don't have the stomach for this.

ActionView suffers from two fundamental problems. ERB is the first.
ERB stands for Embedded RuBy. You can write an entire application
inside an ERB template. This is a major flaw. It can be avoid, but
it's not in 99% of cases. Using a logic less template is the only
correct way to write templates. ERB allows you to put logic in
templates so it eventually happens. If you cannot put logic into the
template it must go somewhere else. This is correct way to do things.
The templates must be the stupidest part of the entire application.
There is a serious problem if they are not. Using a logic less
language (such as Mustache) forces you to revaluate your entire
approach to the presentation layer. It forces a boundary and single
handily eliminates all common problems inside Rails templates.

The second problem exacerbates the first. Templates are executed in
the controller's action's binding. This means they have access to the
local and global scope. Want to call out to another class, you can.
This ability always leads to logic in templates and increased
complexity. Templates should have one view model that exposes
everything they need. Nothing more and nothing else. Using a logic
less template language forces this implementation.

ActionView’s helpers are used to offload logic from the template into
a Ruby module. This is not enough. All helper modules are available
globally, you cannot decide which templates use which helper modules.
This encourages a mishmash of methods where it’s hard to locate where
things actually happen and what methods are available. Eventually
helpers depend on instance variables set in other places and things
become an untenable mess.

ActionView and ERB is a dangerous combination. It's almost designed to
acquire technical debt. A View Model and logic less template setup
could (and has been implemented for ActionView. However it's easier to
just forgo the entire thing if needs to be fundamentally changed.
Architectures and libraries that encourage technical debt should be
avoided. I will say this: those helpers are damn nice. I'm looking at
you `distance_of_time_in_words`. 

### ActionController

ActionController is the best part of Rails. It does a wonderful job of
handling incoming HTTP requests and returning HTTP responses. It
handles responding in multiple formats nicely and the routing works
very well. It's easy to do protocol level things as well. Controllers
can set HTTP cache headers and handle stale responses with ease.
There'd be no problem this small subset of functionality was used.
ActionController has problems just like the other components. The
problems come from what happens inside the methods. 

The controller's job is to make things happen. There are two schools
of thought: fat model/skinny controller or fat controller/dumb model.
The former leads to the problems described in the ActiveRecord
section. The latter means putting application specific logic inside
the controller, thus coupling your application to an HTTP delivery
mechanism violating a fundamental boundary. Fat model/skinny
controller usually leads to brittle tests with a ton of mocking and
stubbing. They usually end up matching the code line by line and
provide no value. Putting logic into the controllers means the tests
must go through HTTP.

*insert something about filters (aka callbacks in controllers)*

*insert something about strong_parameters*

These are not problems with ActionController itself. It has everything to do
with how it's used. Unfortunately getting ActionDispatch working outside of
Rails is a major task. It's not worth the hassle if only HTTP interactions are
required.

### ActiveModel

I was so happy when I heard that Rails 3 was extracting out all the stuff from
ActiveRecord into ActiveModel. It was finally going to be easy to use
validations in other classes. ActiveModel::Validations is really the only
useful module from a reusability perspective. How many people are using
ActiveModel in a project just for the validation module? I'm one of those
people. ActiveModel seems to exist for a few reasons: provide validations,
allow objects to pollute themselves with callbacks, and naming (that module
that makes objects work with forms). ActiveModel is in this weird place. It
extracts behavior from ActiveRecord so other libraries can integrate with the
framework, but it doesn't provide a solid reusability story completely outside
of rails.

### Rails as a Framework

All the core component's problems are connected to Rail's implementation of
MVC. The models are ActiveRecord instances. Controllers dump everything off to
the model, then the controller's scope is used to render an ERB template.
ActiveRecord semantics propagate through all layers. Views start taking to
models, controllers render views and talk to models. Everything is talking to
everything and there are no boundaries. Rails design does not encourage
technical investment. It encourages technical debt and in most cases actually
encourages it. Rails does not being enough to the table to be accepted as an
approbate delivery mechanism. It's components are semi reusable but don't offer
enough flexibility. Some components must fundamentally change to work in this
context. Requiring rails will also make things slower. Rails boot times have
never been fast. Rail's position is build your app in Rails. This is wrong
because it violates the delivery mechanism boundary. Build the application then
create a delivery mechanism. The application is not the delivery mechanism.
This is why it will never work.
