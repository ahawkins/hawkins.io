---
title: Handling Data Changes in NoSQL Documents
layout: post
---

RDMS enforce rigid schemas. This is a benefit and a curse. Changes in
the schema mean downtime and potentially dangerous migrations. NoSQL
datastores do not have the same problem. It is possible to handle data
changes in the application. Costly migrations are no longer a problem.
Thinking so is dangerous. You must abandon the constraints of an old
technology when moving to a new one. Writing migrations for a
schemaless datastore is blasphemy--and it is avoidable.

It is important to separate data access and persistence in every
application. Creating a boundary makes it easy to add logic on one
side without affecting the other. Given a proper boundary between
persisted objects and the domain objects it is possible to insert a
quasi-mapper. The "mapper" instantiates a proxy that knows how to read
one one schema version and write in another. This strategy migrates
documents when they're accessed. However it will create problem if the
entire collection must be queried since each document is in a
different format. All that being said, time to get into some code.

This post assumes there is proper separation between persistence and
domain objects using the repository pattern. Here is an
[implementation](http://hawkins.io/2013/10/implementing_the_repository_pattern/).
This strategy uses [prox](http://rubygems.org/gems/prox) as a transparent proxy.
The proxy classes will report the correct class.

The Mongoid document will include a `version` field. The field is used
to look up the correct proxy class. The proxy class ensures each
document provides the same interface regardless of the document's
underlying data. Implementing the adapter is straight forward.

    class Ad
      include Mongoid::Document

      field :version, type: String
    end

    class AdWithPriceHash < Prox
      def price
        super.fetch(:amount)
      end
    end

    class AdWithMultiplePhoneNumbers < Prox
      def phone_number
        super.first
      end

      def save
        # do the custom stuff here to write the data into
        # the most current format
        self.version = 'whatever_the_current_version_is'
        super
      end
    end

    class MongoidAdapter
      def find(klass, id)
        wrap(Ad.find(id))
      end

      def wrap(ad)
        begin
          "Ad#{ad.version.classify}".constantize.new ad
        rescue NameError 
          raise "Do not know how to handle #{ad.version}"!
        end
      end
    end

That's all there is to it. Happy hacking.
