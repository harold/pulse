class Answer < Sequel::Model
	many_to_one :question

	# Number of seconds below which to count a new answer as an update instead
	UPDATE_WINDOW = 45

	def self.update_or_create( values, update_window=UPDATE_WINDOW )
		# TODO: Instead of deleting and re-adding a new record, is there any good reason to perhaps actually update the last record(s)?
		similar = filter( :user_id=>values[:user_id], :question_id=>values[:question_id] )
		recent  = similar.filter( 'epoch >= ?', values[:epoch] - UPDATE_WINDOW )
		recent.delete
		self.create( values )
	end
end