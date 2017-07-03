require "faraday"

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

require "./lib/logging"
Logging.log_destination = 'app.log'

require './models/api_user'
require './models/setting'
require './models/webinar'


logger = Logger.new('app.log')
logger.level = Logger::DEBUG