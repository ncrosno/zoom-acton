require 'sinatra'
require 'active_record'
require 'yaml'

CONFIG = YAML.load_file('config/config.yml')

# ActiveRecord::Base.establish_connection(
#   :adapter  => "mysql2",
#   :host     => "localhost",
#   :username => "root",
#   :password => "",
#   :database => "zoom_acton"
# )

db = CONFIG["database"]
puts "DB: #{db}"
puts db["user"]

ActiveRecord::Base.establish_connection(
    :adapter => db["adapter"],
    :host     => db["host"],
    :username => db["username"],
    :password => db["password"],
    :encoding => 'utf8'
)

class User < ActiveRecord::Base
end

ActiveRecord::Migration.create_table :users do |t|
  t.string :name
end

class App < Sinatra::Application
end

get '/' do
  p User.all
end
