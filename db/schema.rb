# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170701000553) do

  create_table "api_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "api_key"
    t.string "email"
    t.index ["api_key"], name: "index_api_users_on_api_key", unique: true
    t.index ["email"], name: "index_api_users_on_email", unique: true
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "key"
    t.string "val"
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
  end

  create_table "webinars", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "webinar_id"
    t.string "campaign_id"
    t.string "host_id"
    t.index ["campaign_id"], name: "index_webinars_on_campaign_id", unique: true
    t.index ["webinar_id"], name: "index_webinars_on_webinar_id", unique: true
  end

end
