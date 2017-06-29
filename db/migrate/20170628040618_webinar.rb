class Webinar < ActiveRecord::Migration[5.1]

  def up
    create_table :webinars do |t|
      t.string :webinar_id
      t.string :campaign_id
    end
  end

  def down
    drop_table :webinars
  end

end
