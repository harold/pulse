class Question < Sequel::Model
	many_to_one :user
	one_to_many :answers, :order=>:epoch
	def timestamped_answers( user_id )
		answers_dataset.filter( :user_id=>user_id ).select(:epoch,:value).map{ |a| [a.epoch,a.value] }
	end
end

class QuestionPref < Sequel::Model
	unrestrict_primary_key
	many_to_one :user
	many_to_one :question
end