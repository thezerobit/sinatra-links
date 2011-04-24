require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions

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

#filters

before do
  @user = User.get(session[:user_id])
end

# root page
get '/' do
  haml :root
end

get '/signup' do
  haml :simpleform, :locals => {
    :dest => '/signup',
    :action => 'Sign Up!',
    :object => User.new,
    :data => {},
  }
end

post '/signup' do
  input_hash = {}
  User.properties.select{|p| p.form_field?}.map{|p| p.name}.each do |n|
    input_hash[n] = params[n]
  end
  new_user = User.create(input_hash)
  if new_user.saved?
    haml :notification, :locals => {:message => "User #{new_user[:username]} created."}
  else
    input_hash[:password] = ''
    haml :simpleform, :locals => {
      :dest => '/signup',
      :action => 'Sign Up!',
      :object => new_user,
      :data => input_hash,
    }
  end
end

get '/login' do
  haml :login, :locals => { :message => '' }
end

post '/login' do
  user = User.first :username => params[:username]
  if user and user.password == params[:password]
    @user = user
    session.clear
    session[:user_id] = @user.id
    redirect '/'
  else
    haml :login, :locals => { :message => 'Invalid Login Details' }
  end
end

get '/logout' do
  session.clear
  redirect '/'
end
