require "sinatra"
require "sinatra/content_for"
require "sinatra/reloader"
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
  redirect "/timeline/#{@username}"
end

get "/timeline/:username" do
  @username = params[:username]
  @slanders = @storage.show_all_slanders
  erb :timeline
end

get "/profile/:username" do
  @username = params[:username]
  @slanders = @storage.slanders_for_profile(@username)
  erb :profile
end

get "/new_slander/:username" do
  @username = params[:username]
  erb :new_slander
end

post "/profile/:username" do
  paragraph = params[:new_slander]
  username = params[:username]
  id = @storage.username_to_username_id(username)
  @storage.create_new_slander(paragraph, id)
  redirect "/timeline/#{username}"
end