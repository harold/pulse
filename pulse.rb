require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'sequel'
require 'digest/sha1'
require 'rack-flash'
require 'logger'

enable :sessions
use Rack::Flash

COOKIE_NAME = "pulse-login"

configure do
	DB = Sequel.connect( ENV['DATABASE_URL'] || 'sqlite://pulse.db' )
	DB.logger = Logger.new STDOUT
	require "model/user"
	require "model/question"
	require "model/answer"
end

before do
	path = request.path_info
	unless path[/login|signup/i] or path[/(ico|css|js|png)$/]
		cookie = request.cookies[COOKIE_NAME]
		if cookie
			email, password = cookie.split("::")
			@user = User[:email=>email, :password=>password]
		end
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
	@user    = User[:email=>email, :password=>password]
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
	password = hash_password( params[:password] )
	@user = User[:email=>email]
	
	if @user
		redirect '/'
	else
		User.create(:email=>email,:password=>password)
		@user = User[:email=>email, :password=>password]
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
	@questions = @user.visible_questions
	@values = {}
	@questions.each{ |q| @values[q.pk] = q.timestamped_answers(@user.pk) }
	@custom_js = "/index.js"
	haml :index
end

post '/addquestion/?' do
	Question.create( :text=>params[:text], :user_id=>@user.pk )
	redirect '/'
end

post '/answer/?' do
	value = params[:value].to_i
	question_id = params[:question_id][1..-1].to_i
	Answer.create(
		:user_id=>@user.pk,
		:question_id=>question_id,
		:value=>value,
		:epoch=>Time.now.to_i)
	answers = Question[question_id].timestamped_answers(@user.pk)
	
	"{values:#{answers.inspect}}"
end

post '/detaildata/?' do
	question_id = params[:question_id].to_i
	answers = Question[question_id].timestamped_answers(@user.pk)
	
	"{values:#{answers.inspect}}"
end

get "/detail/:question_id" do
	question_id = params[:question_id].to_i
	@question = Question[question_id]
	@custom_js = "/detail.js"
	haml :detail
end

# This action is a fallback for the JS-disabled
get "/hide/:question_id" do
	question_id = params[:question_id].to_i
	pref = QuestionPref.find_or_create( :question_id=>question_id, :user_id=>@user.pk )
	pref.update( :priority=>-1 )
	redirect '/'
end

post "/hide/:question_id" do
	question_id = params[:question_id].to_i
	pref = QuestionPref.find_or_create( :question_id=>question_id, :user_id=>@user.pk )
	pref.update( :priority=>-1 )
	"OK"
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