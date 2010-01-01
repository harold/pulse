class Answer < Sequel::Model
	# Number of seconds below which to count a new answer as an update instead
	UPDATE_WINDOW = 60 * 1
	many_to_one :question

	def before_create
		similar = self.class.filter( :user_id=>self.user_id, :question_id=>self.question_id )
		similar.filter( 'epoch >= ?', self.epoch - UPDATE_WINDOW ).delete
		super
	end
end