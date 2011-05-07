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
end

#filters

before do
  @user = User.get(session[:user_id])
end

# root page
get '/' do
  links = Link.first 10, :order => [ :votes.desc ]
  snippets = Snippet.first 10, :public => true, :order => [ :votes.desc ]
  erb :root, :locals => { :links => links, :snippets => snippets }
end

get '/signup' do
  redirect '/' if @user
  erb :simpleform, :locals => {
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
    erb :notification, :locals => {:message => "User #{new_user[:username]} created."}
  else
    input_hash[:password] = ''
    erb :simpleform, :locals => {
      :dest => '/signup',
      :action => 'Sign Up!',
      :object => new_user,
      :data => input_hash,
    }
  end
end

get '/login' do
  erb :login, :locals => { :message => '' }
end

post '/login' do
  user = User.first :username => params[:username]
  if user and user.password == params[:password]
    @user = user
    session.clear
    session[:user_id] = @user.id
    redirect '/'
  else
    erb :login, :locals => { :message => 'Invalid Login Details' }
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/links' do
  links = Link.all :order => [ :votes.desc ]
  erb :links, :locals => { :links => links, :tag => 'All'}
end

get '/links/:tag_name' do
  links = Link.all :order => [ :votes.desc ]
  links = links.map{ |x| x }.select{ |l| l.linktag.map{ |t| t.name }.include? params[:tag_name] }
  erb :links, :locals => { :links => links , :tag => "\"#{params[:tag_name]}\""}
end

get '/add_link' do
  redirect '/' if !@user
  erb :linkform, :locals => {
    :dest => '/add_link',
    :action => 'Add Link',
    :object => Link.new(:address => 'http://'),
    :data => {:tags => ''},
  }
end

post '/add_link' do
  redirect '/' if !@user
  input_hash = {
    :name => params[:name],
    :address => params[:address],
    :user => @user,
  }
  tag_text = params[:tags]
  link = Link.create(input_hash)
  if link.saved?
    link.save_tags tag_text
    erb :notification, :locals => {:message => "Link created."}
  else
    erb :linkform, :locals => {
      :dest => '/add_link',
      :action => 'Add Link',
      :object => link,
      :data => {:tags => tag_text},
    }
  end
end

get '/edit_link/:link_id' do
  redirect '/' if !@user
  link = Link.get(params[:link_id])
  redirect '/links' if !link
  redirect '/links' if @user != link.user
  tag_text = link.linktag.map{|t| t.name}.join(' ')
  erb :linkform, :locals => {
    :dest => "/edit_link/#{link.id}",
    :action => 'Update Link',
    :object => link,
    :data => {:tags => tag_text},
  }
end


post '/edit_link/:link_id' do
  redirect '/' if !@user
  input_hash = {
    :name => params[:name],
    :address => params[:address],
  }
  link = Link.get(params[:id])
  redirect '/' if !link
  redirect '/' if @user != link.user
  saved = link.update(input_hash)
  tag_text = params[:tags]
  if saved
    link.save_tags tag_text
    erb :notification, :locals => {:message => "Link updated."}
  else
    erb :simpleform, :locals => {
      :dest => "/edit_link/#{link.id}",
      :action => 'Update Link',
      :object => link,
      :data => {:tags => tag_text},
    }
  end
end

get '/vote_link' do
  redirect '/' if !@user
  link = Link.get(params[:link_id])
  if link and link.user != @user
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
  if link and link.user != @user
    linkvote = Linkvote.first({:user => @user, :link => link})
    linkvote.destroy if linkvote
    link.votes = Linkvote.count(:link => link)
    link.save
  end
  redirect params[:return_to]
end

# snippet stuff:

get '/snippets' do
  snippets = Snippet.all :public => true, :order => [ :votes.desc ]
  erb :snippets, :locals => { :snippets => snippets, :tag => 'Public'}
end

get '/my_snippets' do
  redirect '/' if !@user
  snippets = Snippet.all :user => @user, :order => [ :votes.desc ]
  erb :snippets, :locals => { :snippets => snippets, :tag => 'My'}
end

get '/snippets/:tag_name' do
  snippets = Snippet.all :public => true, :order => [ :votes.desc ]
  snippets = snippets.map{ |x| x }.select{ |l| l.snippettag.map{ |t| t.name }.include? params[:tag_name] }
  erb :snippets, :locals => { :snippets => snippets , :tag => "\"#{params[:tag_name]}\""}
end

get %r{^/snippet/([a-zA-Z0-9]{8})$} do |url_key|
  snippet = Snippet.first(:url => url_key)
  redirect '/' if !snippet
  erb :snippet_page, :locals => { :snippet => snippet }
end

get '/add_snippet' do
  redirect '/' if !@user
  erb :snippetform, :locals => {
    :dest => '/add_snippet',
    :action => 'Add Snippet',
    :object => Snippet.new(:name => 'Untitled'),
    :data => {:tags => ''},
  }
end

post '/add_snippet' do
  redirect '/' if !@user
  input_hash = {
    :name => params[:name],
    :content => params[:content],
    :public => params[:public] != nil,
    :url => Snippet.generate_url,
    :user => @user,
  }
  tag_text = params[:tags]
  snippet = Snippet.create(input_hash)
  if snippet.saved?
    snippet.save_tags tag_text
    redirect '/snippet/' + snippet.url
    # erb :notification, :locals => {:message => "Snippet created."}
  else
    erb :snippetform, :locals => {
      :dest => '/add_snippet',
      :action => 'Add Snippet',
      :object => snippet,
      :data => {:tags => tag_text},
    }
  end
end

get '/edit_snippet/:snippet_id' do
  redirect '/' if !@user
  snippet = Snippet.get(params[:snippet_id])
  redirect '/snippets' if !snippet
  redirect '/snippets' if snippet.user_id != @user.id
  tag_text = snippet.snippettag.map{|t| t.name}.join(' ')
  erb :snippetform, :locals => {
    :dest => "/edit_snippet/#{snippet.id}",
    :action => 'Update Snippet',
    :object => snippet,
    :data => {:tags => tag_text},
  }
end


post '/edit_snippet/:snippet_id' do
  redirect '/' if !@user
  input_hash = {
    :name => params[:name],
    :content => params[:content],
    :public => params[:public] != nil,
  }
  snippet = Snippet.get(params[:id])
  redirect '/' if !snippet
  redirect '/' if snippet.user_id != @user.id
  saved = snippet.update(input_hash)
  tag_text = params[:tags]
  if saved
    snippet.save_tags tag_text
    redirect '/snippet/' + snippet.url
    # erb :notification, :locals => {:message => "Snippet updated."}
  else
    erb :simpleform, :locals => {
      :dest => "/edit_snippet/#{snippet.id}",
      :action => 'Update Snippet',
      :object => snippet,
      :data => {:tags => tag_text},
    }
  end
end

get '/vote_snippet' do
  redirect '/' if !@user
  snippet = Snippet.get(params[:snippet_id])
  if snippet and snippet.user != @user
    snippetvote = Snippetvote.first_or_create(
      {:user => @user, :snippet => snippet},
      {:user => @user, :snippet => snippet})
    snippet.votes = Snippetvote.count(:snippet => snippet)
    snippet.save
  end
  redirect params[:return_to]
end

get '/unvote_snippet' do
  redirect '/' if !@user
  snippet = Snippet.get(params[:snippet_id])
  if snippet and snippet.user != @user
    snippetvote = Snippetvote.first({:user => @user, :snippet => snippet})
    snippetvote.destroy if snippetvote
    snippet.votes = Snippetvote.count(:snippet => snippet)
    snippet.save
  end
  redirect params[:return_to]
end
