class Question < Sequel::Model
	many_to_one :user
	one_to_many :answers, :order=>:epoch
	one_to_many :question_prefs
	
	def timestamped_answers( user_id )
		answers.select{ |a| a.user_id==user_id }.map{ |a| [a.epoch,a.value] }
	end
	def hidden_for?( user_id )
		pref = question_prefs.select{ |qp| qp.user_id==user_id }.first
		pref && pref[ :priority ] < 0
	end
end

class QuestionPref < Sequel::Model
	unrestrict_primary_key
	many_to_one :user
	many_to_one :question
end