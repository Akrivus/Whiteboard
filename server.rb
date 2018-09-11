require 'sinatra'
require 'sinatra/cookies'
require 'uri'
require 'sqlite3'
require 'sequel'

DB = Sequel.connect('sqlite://database.db')
DB.create_table? :entries do
	Integer	:creation
	String	:message
	String	:x
	String	:y
end

URL = "/wb"
enable :sessions
set :server, 'webrick'
set :erb, :layout => :_default
set :port, 2576

post "/create" do
	if (/<.*script.*>| on(.*)\=/i =~ params["message"]).nil?
		DB.from(:entries).insert({
			:creation => Time.now.to_i,
			:message => params["message"],
			:x => params["x"],
			:y => params["y"]
		})
	end
	redirect URL+"/"
end
get "/" do
	if params["blank"] == "on"
		erb :index, :locals => {:writings => DB.from(:entries).all}, :layout => :_empty
	else
		erb :index, :locals => {:writings => DB.from(:entries).all}
	end
end
get "/create" do
	erb :create, :locals => {:writings => DB.from(:entries).all, :params => params}
end
not_found do
	erb :index, :locals => {:writings => DB.from(:entries).all}
end