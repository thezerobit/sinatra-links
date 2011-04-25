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
  alias_method :u, :escape
  alias_method :templ, :erb # switch :erb to :haml, to use haml templates
end

#filters

before do
  @user = User.get(session[:user_id])
end

# root page
get '/' do
  links = Link.first 10, :order => [ :votes.desc ]
  templ :root, :locals => { :links => links }
end

get '/signup' do
  redirect '/' if @user
  templ :simpleform, :locals => {
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
    templ :notification, :locals => {:message => "User #{new_user[:username]} created."}
  else
    input_hash[:password] = ''
    templ :simpleform, :locals => {
      :dest => '/signup',
      :action => 'Sign Up!',
      :object => new_user,
      :data => input_hash,
    }
  end
end

get '/login' do
  templ :login, :locals => { :message => '' }
end

post '/login' do
  user = User.first :username => params[:username]
  if user and user.password == params[:password]
    @user = user
    session.clear
    session[:user_id] = @user.id
    redirect '/'
  else
    templ :login, :locals => { :message => 'Invalid Login Details' }
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/links' do
  links = Link.all :order => [ :votes.desc ]
  templ :links, :locals => { :links => links }
end

get '/add_link' do
  redirect '/' if !@user
  templ :simpleform, :locals => {
    :dest => '/add_link',
    :action => 'Add Link',
    :object => Link.new,
    :data => {:address => 'http://'},
  }
end

post '/add_link' do
  redirect '/' if !@user
  input_hash = { 
    :name => params[:name],
    :address => params[:address],
    :user => @user,
  }
  new_link = Link.create(input_hash)
  if new_link.saved?
    templ :notification, :locals => {:message => "Link created."}
  else
    templ :simpleform, :locals => {
      :dest => '/add_link',
      :action => 'Add Link',
      :object => new_link,
      :data => input_hash,
    }
  end
end

get '/vote_link' do
  redirect '/' if !@user
  link = Link.get(params[:link_id])
  if link
    linkvote = Linkvote.first_or_create(
      {:user => @user, :link => link},
      {:user => @user, :link => link})
    link.votes = Linkvote.count(:link => link)
    link.save
  end
  redirect params[:return_to]
end

get '/unvote_link' do
  redirect '/' if !@user
  link = Link.get(params[:link_id])
  if link
    linkvote = Linkvote.first({:user => @user, :link => link})
    linkvote.destroy if linkvote
    link.votes = Linkvote.count(:link => link)
    link.save
  end
  redirect params[:return_to]
end

