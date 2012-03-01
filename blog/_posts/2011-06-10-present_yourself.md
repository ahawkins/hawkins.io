---
layout: post
title: Present Yourself - Presenters in Rails
tags: [rails, double-leet-hax]
---

Presenters are one of those interesting things that you don't hear about
very much. They are mentioned, and then flutter in the wind. If you
google "presenters rails" you'll get some links from a few years ago and
that's about it. There is perhaps some useful information there. Maybe
you find something on cells. That's most likely not what you want. I'm
taking about presenters (insert Alan Iverson practice voice). Presenters
are object designed to encapsulate information required to create a
view. They slim down controllers and encourage view reusability. This
post describes how I started using presenters and why it worked.

## The Backstory - That's a God Damn Ton of Instance Variables

I work on a complex project. It's not one of those cookie-cutter Rails
apps that deals with practically generated code. There is some real
business going on here. Views are complicated things and it takes a fair
amount of information to render views for certain objects. Here is an
example of what I'm talking about for one page.

1. The record itself.
2. All the associated notes
3. All the associated todos
4. All the associated extra fields (think EAV)
5. All the associated deals
6. All the associate activities (with fancy filtering. This alone is
   massive where each activity as it's own forms and required stuff)
7. Statistics (3 different tables, 30 different statistics, custom
   ranges)
8. A new email
9. A new sms
10. A new meeting
11. A new deal
12. The list goes on

Everyone is used to seeing this:

    def show
      @customer = Customer.find params[:id]
    end

That's all well in good for simple applications. What if you have this?

    def show
      @customer = Customer.find params[:id]

      # insert 30 more lines of instantiation
      # and other trickery to get the view to render
    end

That's gonna get old real quick--especially if you have to do that for
many different pages. The controller is becoming ove run run with logic
**only** required for the view. All of that extra cruft is not related
to the actual controller action of taking params and finding and object.
**It's just noise.** The solution is to move all that stuff into an
object that knows how to _present_ that specific view. Why do you want
to to this? I think there are a few reasons.

1. Keep controllers small and stupid. They should be kept small.
2. Extract logic into a class where it's easily testable
3. Encourage view/template reusability since a view requires an object
not a random assortment of instance variables.
4. Keep views stupid since they depend on one object for everything.

Now many of my previous complex controller actions look like this:

    def show
      customer = Customer.find params[:id]
      @presenter = CustomerPresenter.new customer, current_user
    end

At this point, the presenter does all the required instantiation and
other trickery that the view needs.

## Looking at a Presenter

I created a common base class for all the presenters in my application.
I call it ApplicationPresenter. Here's the code: (Rails 2.3)

    class ApplicationPresenter
      extend ActiveSupport::Memoizable
      include ActionController::UrlWriter
      include ActionController::RecordIdentifier

      def self.default_url_options
        ActionMailer::Base.default_url_options
      end

      private
      def t(*args)
        I18n.translate(*args)
      end
    end

This code enables me to do a few things:

1. Memoize all methods so instantiation/querying only happens once
2. Use named route helpers & url_for/polymorphic_url etc in the
   presenter
3. User `dom_id` and things like that. I use `dom_id` a ton in this
   project.
4. Provide `t` in the presenters. This is mostly to prevent the views
   from figuring out how to find text themselves.

The application is very compontentized. Pages are composed of different
components. Each component has their own presenter. A page presenter
will provide an interface for getting a presenter for each component.
That presenter is passed into the partial as a local variable. It works
out pretty well. Here is an example view. Most of the views look like
this:

    -# This is the dashboard type view

    - title @presenter.title

    = render :partial => 'announcements/announcement', :locals => {:presenter => @presenter.announcement_presenter}

    = render :partial => "activities/activities" , :locals => {:presenter => @presenter.activities_presenter}

    = render_statistics @presenter.statistics_presenter

    - content_for :sidebar do

      = render :partial => "todos/widget", :locals => { :presenter => @presenter.todo_widget_presenter }

      = render :partial => 'users/widget', :locals => { :presenter => @presenter.user_widget_presenter }

      = render :partial => 'customers/search_widget'

      = render :partial => 'companies/widget', :locals => {:presenter => @presenter.company_widget_presenter}

Now you know what a basic view looks like, here's the code for that
page's presenter.

    class DashboardPresenter < ApplicationPresenter
      def initialize(user)
        @user = user
      end

      def user_widget_presenter
        UserWidgetPresenter.new @user 
      end
      memoize :user_widget_presenter

      def company_widget_presenter
        CompanyWidgetPresenter.new @user
      end
      memoize :company_widget_presenter

      def todo_widget_presenter
        TodoWidgetPresenter.new @user, @user
      end
      memoize :todo_widget_presenter

      def announcement_presenter
        AnnouncementPresenter.new @user
      end
      memoize :announcement_presenter

      def activities_presenter
        DashboardActivitiesPresenter.new @user, @user
      end
      memoize :activities_presenter

      def statistics_presenter
        DashboardStatisticsPresenter.new @user
      end
      memoize :statistics_presenter

      def title
        t 'dashboard.page_title'
      end
      memoize :title
    end

The main page presenters really don't have much to them. The just create
presenters for all the different components I want on that page.
However, some of the individual presenters can get pretty hairy. I'll
share a simple one first:

    class NotesPresenter < ApplicationPresenter
      def initialize(record)
        @record = record
      end

      def notes
        @record.notes.all(:include => :user)
      end
      memoize :notes

      def show_explanation?
        @record.notes.count == 0
      end
      memoize :show_explanation?

      def explanation
        t('explanations.notes')
      end
      memoize :explanation
    end

Now for the hairy one:

    class DealsPresenter < ApplicationPresenter

      PER_PAGE = 35

      def initialize(user, params)
        @user = user
        @params = params
      end

      def deals
        if @user.is_a?(Manager)
          bucket = account.deals
        else
          bucket = @user.deals
        end

        case filter
        when 'user'
          bucket = bucket.with_user(account.users.find(@params[:user_id]))
        when 'status_pending'
          bucket = bucket.pending
        when 'status_closed'
          bucket = bucket.closed
        when 'status_rejected'
          bucket = bucket.rejected
        when 'status_paid'
          bucket = bucket.paid
        when 'due_this_week'
          bucket = bucket.due_between(Time.zone.now.beginning_of_week..Time.zone.now.end_of_week)
        when 'due_this_month'
          bucket = bucket.due_between(Time.zone.now.beginning_of_month..Time.zone.now.end_of_month)
        when 'due_overdue'
          bucket = bucket.overdue
        else
          bucket
        end

        bucket.paginate :order => "#{ordered_column} #{sort_direction}",
                        :include => [{:customer => :company}, :user],
                        :page => @params[:page],
                        :per_page => PER_PAGE
      end
      memoize :deals

      def filters_presenter
        presenter = FiltersPresenter.new

        presenter.filter I18n.translate('deals.filters.all_deals'), deals_path, :class => (filter == 'all' ? 'selected' : 'unselected')

        text = case filter
               when 'user'
                 I18n.translate('deals.filters.filtered_by_user', :user => account.users.find(@params[:user_id]))
               else
                 I18n.translate('deals.filters.by_user')
               end

        if @user.is_a?(Manager)
          presenter.dropdown text, :class => (filter == 'user' ? 'selected' : 'unselected') do |drop_down|
            account.users.alphabetical.except(@user).each do |user|
              drop_down.filter user, deals_path(:filter => :user, :user_id => user.id)
            end
          end
        end

        text = case filter
               when 'status_pending'
                 I18n.translate('deals.filters.status_pending')
               when 'status_closed'
                 I18n.translate('deals.filters.status_closed')
               when 'status_paid'
                 I18n.translate('deals.filters.status_paid')
               when 'status_rejected'
                 I18n.translate('deals.filters.status_rejected')
               else
                 I18n.translate('deals.filters.status')
               end

        presenter.dropdown text, :class => (filter =~ /status/ ? 'selected' : 'unselected') do |drop_down|
          %w(pending closed paid rejected).each do |status|
            drop_down.filter I18n.translate("deals.states.#{status}"), deals_path(:filter => "status_#{status}") if filter != status
          end
        end

        presenter
      end
      memoize :filters_presenter

      def deal
        Deal.new
      end
      memoize :deal

      def sortable_options
        @params.slice(:filter, :user_id)
      end
      memoize :sortable_options

      def sort_column
        %w(user customer company amount due_on status).include?(@params[:sort]) ? @params[:sort] : 'user'
      end
      memoize :sort_column

      def sort_direction
        @params[:direction] == 'desc' ? 'desc' : 'asc'
      end
      memoize :sort_direction

      def ordered_column
        case sort_column
        when 'user'
          'users.name'
        when 'customer'
          'customers.name'
        when 'company'
          'companies.name'
        when 'amount'
          'deals.value'
        when 'status'
          'deals.state'
        when 'due_on'
          'deals.due_by'
        end
      end
      memoize :ordered_column

      def title
        I18n.translate 'plurals.deals'
      end
      memoize :title

      def statistics_presenter

      end
      memoize :statistics_presenter

      private
      def filter
        %w(user status_pending status_closed status_rejected status_paid
          due_this_week due_this_month due_overdue all).include?(@params[:filter]) ? @params[:filter] : 'all'
      end
      memoize :filter

      def account
        @user.account
      end
      memoize :account
    end

**Note:** this particular presenter is waiting to be refactored. But it
does give you an idea of some of the logic that I removed from the
controlller. It also testifies to the logic required to construct a view
and why it's nice to remove it from the controller.

## Testing Presenters 

I like moving logic out of the controllers because testing controllers
is such a pain in the ass. (I stopped doing it completely actually).
Once your controller starts to do some real work, whatever mocks/stubs
you had in place become too cumbersome to maintain. Sometimes I simply want
to test that a new instance variable is created. Using my presenter, I
could write a test like this:

    class NotesPresenter < ApplicationPresenter
      def note
        Note.new
      end
      memoize :note
    end

    describe NotesPresenter do
      it "should provide a new note for a form" do
        subject.note.should be_new_record
        subject.note.should be_a(Note)
      end
    end

Good luck doing that in a controller action with more complex logic.
It's very easy to test in an isolate class.

Most of my test cases don't do heavy assertions, but verify that a
specific interface is implemented. Most of the logic inside the method
is trivial enough to ignore writing a test case. Instead, I use rspec's
`it_should_behave_like` to specify the presenter provides a certain
interface. Here is the test for the previously mentioned
`DashboardPresenter`:

    require 'spec_helper'

    describe DashboardPresenter do
      def mock_user(stubs = {})
        @mock_user ||= mock_model(User, stubs)
      end

      subject { DashboardPresenter.new(mock_user) }

      it_should_behave_like "a presenter with activities"

      it_should_behave_like "a presenter with todos"

      it_should_behave_like "a presenter with stats"

      it_should_behave_like "a presenter with companies"

      it_should_behave_like "a presenter with a page title"

      it { should respond_to(:user_widget_presenter) }

      it { should respond_to(:announcement_presenter) }
    end


Now for a component presenter:

    require 'spec_helper'

    describe NotesPresenter do
      fixtures :customers

      subject { NotesPresenter.new customers(:teemu) }

      it_should_behave_like "a presenter with an explanation"

      it { should respond_to(:notes) }
    end

## Closing Thoughts

I'm very happy I did this. It makes my view layer much easier to
maintain. It also makes my controllers easy to maintain because of how
simple they are. It also gives me a common object I can pass off to a
view if I need to render it. This happens to me a lot actually. There
are ajax forms that hit different controllers on one page. For example,
if you are on 'companies/1' there is a form to add a todo. Naturally
this goes to `TodosController`. Now the UI for the company page has to
be updated from the `TodosController` in a `js.erb` template. I can
simply instantiate the todos component presenter has use that to
rerender the partial. I don't have to know anything else--the presenter
does all the work for me. 

You can learn more about presenters in this [course](http://www.codeschool.com/courses/rails-best-practices).
You can also learn more about presenters by reading Martin Flower's
[papers](http://www.google.com/search?sourceid=chrome&ie=UTF-8&q=martin+fowler+presenter).

