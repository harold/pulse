class AddUsers < Sequel::Migration
	def up
		create_table :users do
			primary_key :id
			String :email
			String :password
		end
	end
	
	def down
		drop_table :users
	end
end