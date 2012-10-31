---
layout: post
title: "The New Iridium: Architecture Notes"
tags: [javascript]
---

I've been working and speaking about Iridium (and Javascript)
development a lot recently. You may have seen me in Cologne, Hamburg,
Berlin, Paris, or Helsinki. I've been speaking about an integrated
approach. I've been working hard to make that dream come true for myself
and my fellow developers. I'm happy to announce that hydrogen branch of
Iridium was merged last night! This means Iridium can easily be extended
to support new frameworks and use cases.

## Hydrogen: The Base Element

The new Iridium is entirely modular. It's models as a series of
components that are loosely coupled. A class is used to connect
components to other ones and configure them. Iridium is built on top of
[hydrogen](https://github.com/radiumsoftware/hydrogen). Hydrogen is a
framework for building extendable Ruby applications. It provides a
unified framework defining components, sharing Rake tasks, generators,
and command line applications. Hydrogen is still under active
development but the underpinning are strong enough to support Iridium.

Iridium applications are composed of components. There are two
fundamental components: The asset pipeline and the server. Other
secondary components build on top of them. Here's an example:
compass integration uses hooks provided by the pipeline component.
Individiual subsystems are implemented as separate components (testing,
linting etc). Components are the fundamental building block. They
expose other components and be tied together. They are lowest layer for
the next abstraction.

Engines are the next level of abstraction. They act like components but
have code (or assets) that need to be added to the application. Your
Iridium application is an engine. This architecture is very similar to
Rails which uses Railties and Engines. Hydrogen provides the lowest
layer to build Iridium's abstractions on. Engines can do everything can
components can and more.

Here's how Iridium's architecture looks like in code:

```ruby
# Lowest possible abstraction: isolated functionality and
# shared configuration. Hydrogen::Components connect code from
# one system to another
class Hydrogen::Component
end

# Provide a base layer for Iridium's abstractions. This includes things
# like adding application specific callbacks and methods
class Iridium::Component < Hydrogen::Component
end

# The application abstraction. Applications have their own files
# which can be compiled and served. This actually setups the paths
# needed to make the pipeline component work
class Iridium::Engine < Iridium::Component
end

# Provide a base to configure every individual subsystem
# and make everything work together.
class Iridium::Application < Iridium::Engine
end
```

## Architecture Benefits

The architecture's original use case was to support ember integration.
This mean that original behavior would have to be customized. It also
meant that some assets would have to be loaded from gems. Ember
applications need Handlebars templates precompiled. This means applying
a different config setting. 

Here are some exmaples highlighting what can be done because of the new
architecture.

### Engine Assets

Engine have paths. These paths define where to look on the filesystem
for certain kinds of files. Applications are composed of one or more
engines. So an application has a set of paths where things can be loaded
from. This easy to accomplish with rake-pipeline. Rake-pipeline allows
you to pass an array of input directories. The application can simply
construct an array from all the engines to get an array of all the input
paths.

Here's an example from the `Assetfile`

```ruby
output app.build_path.join("javascript")
input app.all_paths[:vendor].expanded do
  app_overrides_engines

  # Skip all the files specified.
  app.config.dependencies.skips.each do |file|
    skip "javascripts/#{file}.js"
  end

  # Use the specified vendor order to create a vendor.js file
  match "**/*.js" do
    engines_first
    ordered_files = app.config.dependencies.files.collect { |f| "javascripts/#{f}.js" }
    concat ordered_files, "vendor.js"
  end
end
```

This means you can have this directory structure and everything will
just work:

```
/application
  /app
    /assets
    /javascripts
    /stylesheets/
  /vendor
    /assets
    /javascripts
    /stylesheets/
/engine
  /app
    /assets
    /javascripts
    /stylesheets/
  /vendor
    /assets
    /javascripts
    /stylesheets/
```

### Pipeline Extendability

The pipeline component makes it easy to hook into the compilation
process. The SASS component uses this hook internally to configure
compass for Iridium apps. Heres an example from the codebase:

```ruby
module Iridium
  class CompassConfiguration < Compass::Configuration::Data
    def initialize
      super "iridium_config"
    end
  end

  class CompassComponent < Component
    # expose a shared compass configuration that can be changed
    # by the application or any other components
    config.compass = CompassConfiguration.new

    config.compass.line_comments = false

    # Hook into the compilation process to configure compass 
    # accodingly each time
    before_compile do |app|
      Compass.reset_configuration!

      app.config.compass.project_path = app.root

      # sprites can come from the application or any engine
      app.config.compass.sprite_load_path = app.all_paths[:sprites].expanded
      app.config.compass.generated_images_path = app.site_path.join('images').to_s

      # stylesheets in the application or any engine can be imported
      app.config.compass.additional_import_paths = [app.vendor_path.join("stylesheets")]

      Compass.add_configuration app.config.compass
    end
  end
end
```

This is just one hook the pipeline component exposes. The pipeline
component also exposes an optimization hook. Say you wanted to create a
component that optimized images. It's very easy to hook this up.

```ruby
class ImageOptimizerComponent < Iridium::Component
  optimize do |pipeline|
    pipeline.match "**/*.jpg" do
      optmize_jpeg_filter
    end

    pipeline.match "**/*.png" do
      optmize_png_filter
    end
  end
end
```

### Engine Environment Configuration

Engines define their own paths. The paths define where to look for
initializers or environment files. The application will correctly load
all these files when it's booted. This means that engines can define
their own configurations for development/test/production/etc. Here's an
example from iridium-ember:

```ruby
# config/production.rb
Iridium::Ember::Engine.configure do
  config.dependencies.swap "ember-debug", :ember

  # compile handlebars files with the ember compiler
  config.handlebars.compiler = Iridium::Ember::HandlebarsFileCompiler

  # strip assertions from our code
  js do |pipeline|
    pipeline.strip %r{^\s*(Ember|Em)\.(assert|deprecate|warn)\((.*)\).*$}
  end

  # compile inline handlebars templates
  js do |pipeline|
    pipeline.replace /((?:Ember|Em)\.Handlebars\.compile)\(['"](.+)['"]\)/ do |foo, _, template|
      Iridium::Ember::InlineHandlebarsCompiler.call template
    end
  end
end
```

These are just a few benefits. The most important benefit is that
Iridium can be extended easily to support new use cases.

## Iridium-Ember

Iridium-Ember is the first and primary Iridium plugin. I'm happy to
annouce that it is **functioning** and usable from master with iridium
from master. It's primary use cases are:

1. Provide an application generator to get going quickly
2. Do all production optimizations (mainly Handlebars precompilation)
3. Provide proper setup/teardown hooks in test mode.

These #1, and #3 are still WIP as ember is still in alpha. #2 is
completely functioning. Anyone with an existing ember app should be able
to use the optimizations.

You clean more about these projects on github:

* [Iridium](https://github.com/radiumsoftware/iridium)
* [Iridium-Ember](https://github.com/radiumsoftware/iridium-ember)
* [Hydrogen](https://github.com/radiumsoftware/hydrogen)
