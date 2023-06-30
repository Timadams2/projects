require "sinatra"
require "sinatra/content_for"
require "sinatra/reloader" if development?
require "tilt/erubis"

require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, escape_html: true
  also_reload "database_persistence.rb"
end

helpers do
  def sort_slanders(slanders, &block)
    slanders.each(&block)
  end
  
  def logged_in?
    session[:username]
  end
end

def error_for_new_slander(slander)
  slander.chars.size >= 140 || (slander.chars.size - slander.chars.count(' ')) <= 0
end

before do
  @storage = DatabasePersistence.new
end

get "/" do
  redirect "timeline/:username"
end

get "/profile/login" do
  erb :login
end

post "/profile/login" do
  @username = params[:username]
  session[:sucess] = "Logged in as #{@username}"
  session[:username] = @username
  redirect "/timeline/#{@username}"
end

get "/timeline/:username" do
  if session[:username]
    @username = session[:username]
    @slanders = @storage.show_all_slanders
    erb :timeline
  else 
    redirect "/profile/login"
  end
end

get "/profile/:username" do
  if session[:username]
    @username = session[:username]
    @slanders = @storage.slanders_for_profile(@username)
    erb :profile
  else 
    redirect "profile/login"
  end
end

get "/new_slander/:username" do
  @username = session[:username]
  if session[:username]
    @username = session[:username]
    @slanders = @storage.slanders_for_profile(@username)
    erb :profile
  else 
    redirect "profile/login"
  end
  erb :new_slander
end

post "/profile/:username" do
  paragraph = params[:new_slander]
  username = params[:username]
  error = error_for_new_slander(paragraph)
  if error
    session[:error] = 'Slanders must be between 1 and 140 characters'
    redirect "/timeline/#{username}"
  else 
    session[:success] = 'Slander Posted'
    id = @storage.username_to_username_id(username)
    @storage.create_new_slander(paragraph, id)
    redirect "/timeline/#{username}"
  end
end

post "/profile/:username/delete/:paragraph" do
  @paragraph = params[paragraph]
  delete_slander(@paragraph)
end

get "/profile/signout" do
  session.delete(:username)
  redirect "/profile/login"
end