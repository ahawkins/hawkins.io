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