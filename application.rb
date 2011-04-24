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
  fields = User.form_fields
  haml :simpleform, :locals => {
    :fields => fields,
    :klass => User,
    :dest => '/signup',
    :action => 'Sign Up!',
    :object => User.new,
    :data => {},
  }
end

post '/signup' do
  fields = User.form_fields
  input_hash = {}
  fields.each do |field|
    sym = field[:name].intern
    input_hash[sym] = params[sym]
  end
  new_user = User.create(input_hash)
  if new_user.saved?
    haml :notification, :locals => {:message => "User #{new_user[:username]} created."}
  else
    input_hash[:password] = ''
    haml :simpleform, :locals => {
      :fields => fields,
      :dest => '/signup',
      :action => 'Sign Up!',
      :object => new_user,
      :data => input_hash,
    }
  end
end

