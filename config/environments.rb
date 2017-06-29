require 'yaml'

CONFIG = YAML.load_file('config/config.yml')

db = CONFIG["database"]

r = ActiveRecord::Base.establish_connection(
    :adapter => db["adapter"],
    :database => db["database"],
    :host     => db["host"],
    :username => db["username"],
    :password => db["password"],
    :port => db["port"],
    :encoding => 'utf8'
)
