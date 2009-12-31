Class.new( Sequel::Migration ) do
	def up
		create_table :answers do
			primary_key :id
			foreign_key :user_id, :users
			foreign_key :question_id, :questions
			Integer :value
			Integer :epoch
		end
	end
	
	def down
		drop_table :answers
	end
end