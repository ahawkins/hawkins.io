require "rack/jekyll"

Rack::Mime::MIME_TYPES.merge!('.otf', 'application/octet-stream')

run Rack::Jekyll.new
