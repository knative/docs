require 'sinatra'

set :bind, '0.0.0.0'
set :port, ENV['PORT']

get '/' do
  target = ENV['TARGET'] || 'World'
  "Hello #{target}!\n"
end
