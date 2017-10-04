class ZoomApi

  include Logging

  def initialize 
    @conn = Faraday.new(:url => CONFIG["zoom_api"]["host"]) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end


  
  def sync_all_webinars_to_acton
    # First make sure all webinars are imported locally so we have the host_id to work with
    import_webinar_list

    # Now loop through all the webinars and sync their data to ActOn 
    Webinar.where('host_id is not null and campaign_id is not null').each do |w|
      logger.debug "Webinar: #{w.webinar_id} / #{w.campaign_id}"
      sync_webinar_to_acton(w)
      sleep 60 # To help with throttling
    end
  end



  def import_webinar_list
    # Get all users from Zoom, then filter to just webinar users
    user_data = list_users
    users = user_data["users"]
    webinar_users = users.select{|u| u["enable_webinar"]==true}
    
    # Get all webinars for each user & assign correct host_id to each webinar
    webinar_users.each do |u|
      webinar_data = list_webinars(u["id"])
      webinars = webinar_data["webinars"]
      cnt = webinars ? webinars.length : 0
      logger.debug "#{u["email"]}: found #{cnt}"
      next unless cnt > 0

      webinars.each do |zw|
        w = Webinar.find_or_initialize_by(webinar_id: zw["id"])
        w.host_id = u["id"]
        w.save
      end
    end
  end



  def sync_webinar_to_acton(w)
    users = get_users_for_webinar(w)

    logger.debug "Found #{users.length} to sync."
    return unless users.length > 0

    ActOnApi.new.sync_webinar(w,users)
  end



  def get_users_for_webinar(w)
    logger.debug "Getting users for webinar..."
    attendees = []
    page_count = 1
    page_num = 1
    
    data = {
      page_number: page_num,
      host_id: w.host_id,
      id: w.webinar_id
    }
    
    while page_num <= page_count
      resp = sendRequest('/v1/webinar/registration', data)
      page_num += 1
      page_count = resp["page_count"] || 0
      data[:page_number] = page_num
      attendees += resp["attendees"] if resp["attendees"]
    end

    return attendees
  end




  def list_webinars(host_id)
    resp = sendRequest('/v1/webinar/list/registration',{host_id: host_id})
  end



  def list_users
    resp = sendRequest('/v1/user/list')
  end



  def sendRequest(path, data={})

    data['api_key']    = CONFIG["zoom_api"]["api_key"]
    data['api_secret'] = CONFIG["zoom_api"]["api_secret"]
    data['data_type']  = 'JSON'

    resp = @conn.post path, data
  
    return JSON.parse(resp.body)
  end


end