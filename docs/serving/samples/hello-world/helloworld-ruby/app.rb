require 'sinatra'

set :bind, '0.0.0.0'

get '/' do
  target = ENV['TARGET'] || 'World'
  "Hello #{target}!\n"
end
