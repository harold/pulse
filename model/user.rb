class User < Sequel::Model
	# Questions created by the user
	one_to_many :questions
	one_to_many :question_prefs
	
	def visible_questions
		shown_questions  = Question.exclude( :id=>hidden_questions.select(:id) )
		shown_questions.left_outer_join( :question_prefs, :question_id=>:id ).order( :priority )
	end
	
	def hidden_questions
		Question.filter( :id=>question_prefs_dataset.filter{ priority < 0 }.select(:question_id) )
	end
end