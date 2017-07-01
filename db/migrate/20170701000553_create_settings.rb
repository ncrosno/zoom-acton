class CreateSettings < ActiveRecord::Migration[5.1]
  def up
    create_table :settings do |t|
      t.string :key
      t.string :val
      t.index :key, unique: true
    end
  end

  def down
    drop_table :settings
  end
end
