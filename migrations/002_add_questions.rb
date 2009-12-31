class AddQuestions < Sequel::Migration
	def up
		create_table :questions do
			primary_key :id
			String :text
			foreign_key :user_id, :users
		end
	end
	
	def down
		drop_table :questions
	end
end