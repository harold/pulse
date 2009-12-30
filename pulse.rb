require 'rubygems'
require 'sinatra'
require 'sequel'

configure do
	DB = Sequel.connect( ENV['DATABASE_URL'] || 'sqlite://pulse.db' )
end

get '/?' do
	@questions = DB[:questions]
	haml :index
end

get '/addquestion/:text' do
	questions = DB[:questions]
	questions.insert(:text => params[:text] )
	redirect '/'
end
