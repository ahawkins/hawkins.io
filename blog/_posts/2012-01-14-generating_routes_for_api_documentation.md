---
layout: post
title: "Generating Routes for API Documentation"
tags: [rails]
---

I recentely came across this situation. I was updating the documenation
for our main API. I have a section which includes all the routes
grouped by resource with HTTP verb. I ran `rake routes` and edited the
output to get it how I wanted. Fast forward a few API revisions with
new routes and routes removed. Doing this process over and over again
would be very tedious. Here's what I wanted to generate:

```
GET    /accounts/:id
PUT    /accounts/:id

POST   /users/:user_id/follow
GET    /users/:user_id/feed
GET    /users
GET    /users/:id
PUT    /users/:id
DELETE /users/:id

POST   /contacts/:contact_id/deals
POST   /contacts/:contact_id/notes
POST   /contacts/:contact_id/todos
POST   /contacts/:contact_id/follow
GET    /contacts/:contact_id/feed
GET    /contacts
POST   /contacts
GET    /contacts/:id
PUT    /contacts/:id
DELETE /contacts/:id

POST   /todos/:todo_id/comments
POST   /todos/:todo_id/reminders
GET    /todos
POST   /todos
GET    /todos/:id
PUT    /todos/:id
DELETE /todos/:id

POST   /deals/:deal_id/comments
POST   /deals/:deal_id/todos
POST   /deals/:deal_id/follow
GET    /deals/:deal_id/feed
GET    /deals
GET    /deals/:id
PUT    /deals/:id
DELETE /deals/:id

POST   /groups/:group_id/todos
POST   /groups/:group_id/follow
GET    /groups/:group_id/feed
GET    /groups
POST   /groups
GET    /groups/:id
PUT    /groups/:id
DELETE /groups/:id

POST   /announcements/:announcement_id/comments
GET    /announcements
POST   /announcements
GET    /announcements/:id
PUT    /announcements/:id
DELETE /announcements/:id

POST   /emails/:email_id/comments
POST   /emails/:email_id/todos
GET    /emails
POST   /emails
GET    /emails/:id
PUT    /emails/:id
DELETE /emails/:id

POST   /sms/:sms_id/comments
POST   /sms/:sms_id/todos
POST   /sms/import
GET    /sms
POST   /sms
GET    /sms/:id
PUT    /sms/:id
DELETE /sms/:id

POST   /ims/:im_id/comments
GET    /ims
POST   /ims
GET    /ims/:id
PUT    /ims/:id
DELETE /ims/:id

POST   /meetings/:meeting_id/comments
POST   /meetings/:meeting_id/todos
POST   /meetings/:meeting_id/reminders
PUT    /meetings/:id/reschedule
PUT    /meetings/:id/cancel
GET    /meetings
POST   /meetings
GET    /meetings/:id
PUT    /meetings/:id
DELETE /meetings/:id

PUT    /invitations/:id/confirm
PUT    /invitations/:id/reject

POST   /phone_calls/:phone_call_id/todos
POST   /phone_calls/:phone_call_id/comments
POST   /phone_calls/import
GET    /phone_calls
GET    /phone_calls/:id
PUT    /phone_calls/:id
DELETE /phone_calls/:id

POST   /notes/:note_id/todos
GET    /notes
GET    /notes/:id
PUT    /notes/:id
DELETE /notes/:id

GET    /reminders
POST   /reminders
GET    /reminders/:id
PUT    /reminders/:id
DELETE /reminders/:id

POST   /campaigns/:campaign_id/follow
POST   /campaigns/:campaign_id/comments
POST   /campaigns/:campaign_id/notes
POST   /campaigns/:campaign_id/call_lists
GET    /campaigns/:campaign_id/feed
GET    /campaigns
POST   /campaigns
GET    /campaigns/:id
PUT    /campaigns/:id
DELETE /campaigns/:id

PUT    /followings/:id/approve
GET    /followings
POST   /followings
GET    /followings/:id
PUT    /followings/:id
DELETE /followings/:id

GET    /products
POST   /products
GET    /products/:id
PUT    /products/:id
DELETE /products/:id

GET    /call_lists
GET    /call_lists/:id
PUT    /call_lists/:id
DELETE /call_lists/:id

GET    /comments
POST   /comments
GET    /comments/:id
DELETE /comments/:id

POST   /bug

POST   /echo
```


I also wanted to group them with spaces by the associated resource.
This was actually pretty easy to do. I opened up github and hit `t`
and searched `routes.rake` to find the source code. Then subclassed 
the generator and called it myself. Took a few tries to get all the 
bugs worked out. The code is pretty easy. Here's the finished product.
Drop it in `api_routes.rake`:

```ruby
desc 'Print out all defined routes used for the api without rails specific information'
task :api_routes => :environment do
  Rails.application.reload_routes!
  all_routes = Rails.application.routes.routes

  require 'rails/application/route_inspector'

  class ApiRouteInspector < Rails::Application::RouteInspector
   def formatted_routes(routes)
      verb_width = routes.map{ |r| r[:verb].length }.max
      path_width = routes.map{ |r| r[:path].length }.max

      routes = routes.reject do |r|
        r[:reqs] =~ /#(new|edit)/
      end

      groups = routes.inject({}) do |set, r|
        section = r[:path].match(/\/([^\/|\(]+)/)[1]

        set[section] ||= []
        set[section] << r
        set
      end

      groups.values.map do |rs|
        rs.map do |r|
          line = "#{r[:verb].ljust(verb_width)} #{r[:path].gsub("(.:format)", '').ljust(path_width)}"
          line = "#{line}\n" if rs.last == r
          line
        end.join("\n")
      end
    end
  end

  inspector = ApiRouteInspector.new
  puts inspector.format(all_routes, ENV['CONTROLLER']).join "\n"
end
```

Then just run `bundle exec rake api_routes` and you'll have some quick
documentation to give to your devs.
