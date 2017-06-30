class CreateWebinars < ActiveRecord::Migration[5.1]

  def up
    create_table :webinars do |t|
      t.string :webinar_id
      t.string :campaign_id
      t.string :host_id
      t.index :webinar_id, unique: true
      t.index :campaign_id, unique: true
    end
  end

  def down
    drop_table :webinars
  end

end
