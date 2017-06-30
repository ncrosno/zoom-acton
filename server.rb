require 'sinatra'  
require "sinatra/activerecord"
require "faraday"

require './config/environments'
require './models/api_user'
require './models/webinar'

get '/' do  
  erb :index
end


# Creates a webinar_id campaign_id set
# Params:
#   api_key
#   webinar_id
#   campaign_id
post '/webinar/create' do

  return unless authenticate

  unless params["webinar_id"] && params["campaign_id"]
    status 500
    body "Error: Please supply api_key, webinar_id, and campaign_id\n"
    return
  end

  w = Webinar.find_or_initialize_by(webinar_id:params["webinar_id"])

  if w.id
    status 500
    body "Error: Webinar already exists.\n"
    return
  end

  set_campaign(w)
  
end




post '/webinar/update' do
  
  return unless authenticate

  unless params["webinar_id"] && params["campaign_id"]
    status 500
    body "Error: Please supply api_key, webinar_id, and campaign_id\n"
    return
  end

  w = Webinar.find_by(webinar_id:params["webinar_id"])

  unless w
    status 500
    body "Error: Webinar not found.\n"
    return
  end

  set_campaign(w)
end



private



def authenticate
  u = ApiUser.find_by(api_key:params["api_key"])
  unless u
    status 500
    body "Error: User not found for api_key\n"
    return false
  end
  return true
end


def set_campaign(w)
  w.campaign_id = params["campaign_id"]
  if w.save
    status 200
    body  "SUCCESS! Updated #{w.webinar_id}\n"
    return false
  else
    status 500
    body "Error: Something went wrong.\n"
    return false
  end
  return true
end