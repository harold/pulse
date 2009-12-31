Class.new( Sequel::Migration ) do
	def up
		create_table :question_prefs do
			foreign_key :user_id,     :users
			foreign_key :question_id, :questions
			primary_key [:user_id, :question_id]
			Integer     :priority
		end
	end
	
	def down
		drop_table :question_prefs
	end
end