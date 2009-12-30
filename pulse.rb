require 'rubygems'
require 'sinatra'
require 'sequel'

get '/?' do
	DB = Sequel.connect( ENV['DATABASE_URL'] || 'sqlite://pulse.db' )
	@questions = DB[:questions]
	haml :index
end

get '/addquestion/:text' do
	DB = Sequel.connect( ENV['DATABASE_URL'] || 'sqlite://pulse.db' )
	questions = DB[:questions]
	questions.insert(:text => params[:text] )
	redirect '/'
end
