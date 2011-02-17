require 'ruby_gems'
require 'bundler'
Bundler.require

require "rack/jekyll"

run Rack::Jekyll.new
