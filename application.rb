require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

# root page
get '/' do
  haml :root
end

get '/signup' do
  fields = [
    { :name => 'username', :title => 'Username', },
    { :name => 'firstname', :title => 'First Name', },
    { :name => 'lastname', :title => 'Last Name', },
    { :name => 'email', :title => 'Email Address', },
    { :name => 'password', :title => 'Password', :type => 'password', },
  ]
  haml :simpleform, :locals => { :fields => fields, :dest => '/signup',
    :action => 'Sign Up!'}
end
