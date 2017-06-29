class CreateApiUsers < ActiveRecord::Migration[5.1]
  def up
    create_table :api_users do |t|
      t.string :api_key
      t.string :email
      t.index :api_key, unique: true
      t.index :email, unique: true
    end
  end

  def down
    drop_table :api_users
  end
end
