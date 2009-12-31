require 'rubygems'
require 'sinatra'
require 'sequel'
require 'digest/sha1'
require 'rack-flash'

enable :sessions
use Rack::Flash

COOKIE_NAME = "pulse-login"

configure do
	DB = Sequel.connect( ENV['DATABASE_URL'] || 'sqlite://pulse.db' )
end

before do
	cookie = request.cookies[COOKIE_NAME]
	if cookie
		email, password = cookie.split("::")
		@user = DB[:users][:email=>email, :password=>password]
	end
	
	path = request.path_info
	unless path[/login|signup/i] or path[/(ico|css|js)$/]
		unless @user
			redirect '/login'
		end
	end
end

template :layout do
	IO.read "views/layout.haml"
end

post '/login/?' do
	email    = params[:email]
	password = hash_password( params[:password])
	@user    = DB[:users][:email=>email, :password=>password]
	if @user
		set_cookie(email,password)
		redirect '/'
	else
		flash[:notice] = "Login failed - try again"
		redirect '/login'
	end
end

get '/login/?' do
	haml :login
end

get '/logout/?' do
	set_cookie('','')
	redirect '/'
end

post '/signup/?' do
	email    = params[:email]
	password = hash_password( params[:password])
	@user = DB[:users][:email=>email]
	
	if @user
		redirect '/'
	else
		DB[:users].insert({:email=>email,:password=>password})
		@user = DB[:users][:email=>email, :password=>password]
		set_cookie(email,password)
		redirect '/'
	end
end

get '/signup/?' do
	haml :signup
end

get '/shared.css' do
	sass :shared
end

get '/?' do
	@questions = DB[:questions]
	@values = {}
	@questions.each do |q|
		@values[q[:id]] = DB[:answers].filter(:user_id=>@user[:id], :question_id=>q[:id]).order(:epoch).select(:epoch,:value).map{ |a| a.values_at(:epoch,:value) }
	end
	@custom_js = "/index.js"
	haml :index
end

post '/addquestion/?' do
	questions = DB[:questions]
	questions.insert(:text=>params[:text],:user_id=>@user[:id])
	redirect '/'
end

post '/answer/?' do
	value = params[:value].to_i
	question_id = params[:question_id][1..-1].to_i
	DB[:answers].insert(
		:user_id=>@user[:id],
		:question_id=>question_id,
		:value=>value,
		:epoch=>Time.now.to_i)
	
	answers = DB[:answers].filter(:user_id=>@user[:id], :question_id=>question_id).order(:epoch).select(:epoch,:value)
	
	"{values:#{answers.map{|a| a.values_at(:epoch,:value)}.inspect}}"
end

post '/detaildata/?' do
	question_id = params[:question_id].to_i
	answers = DB[:answers].filter(:user_id=>@user[:id], :question_id=>question_id).order(:epoch).all
	
	pairs = []
	answers.each do |a|
		pairs << [a[:epoch],a[:value]]
	end

	"{values:#{pairs.inspect}}"
end

get "/detail/:question_id" do
	question_id = params[:question_id]
	@question = DB[:questions].filter(:id=>question_id.to_i).first
	@custom_js = "/detail.js"
	haml :detail
end

helpers do
	def hash_password( password )
		salt = "yomamaain'tgotnorainbowtableforthismother"
		Digest::SHA1.hexdigest(password+salt)
	end
	
	def set_cookie(email, password)
		cookie_value = "#{email}::#{password}"
		response.set_cookie( COOKIE_NAME, {:expires=>Time.now+(10**6), :value=>cookie_value} )
	end
end