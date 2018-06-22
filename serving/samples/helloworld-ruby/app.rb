require 'sinatra'

set :bind, '0.0.0.0'

get '/' do
  target = ENV['TARGET'] || 'NOT SPECIFIED'
  "Hello World: %s!\n" % [target]
end
