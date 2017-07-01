require 'csv'

# Get example curl commands from ActOn documentation here:
# https://developer.act-on.com/documentation/oauth/

class ActOnApi
 
  include Logging

  def initialize

    @client_id = CONFIG['act_on_api']['client_id']
    @client_secret = CONFIG['act_on_api']['client_secret']
    @username = CONFIG['act_on_api']['username']
    @password = CONFIG['act_on_api']['password']

    @access_token = Setting.get('act_on_access_token')
    @refresh_token = Setting.get('act_on_refresh_token')


    @conn = Faraday.new(:url => CONFIG["act_on_api"]["host"]) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    authenticate
  end



  def get_request(path)
    resp = @conn.get do |req|
      req.url path
      req.headers["Authorization"] = "Bearer #{@access_token}"
      req.headers["Cache-Control"] = "no-cache"
    end
    logger.debug "token: #{@access_token} -- get_request: #{resp.inspect}"

    if !resp
      return false
    elsif resp.status == 401
      return false
    elsif !resp.body
      return false
    elsif resp.status == 200
      return JSON.parse(resp.body)
    else 
      return false
    end
  end



  def send_request(path, data={})
    resp = @conn.post path, data
    return JSON.parse(resp.body)
  end



  def authenticate
    # get a token if none
    if !@access_token
      logger.debug "authenticate: no existing token. getting new one"
      get_auth_token
    else
      # if we have a token, make a test call to see if the token works
      #  - if fails, get new auth token
      #  - try first with refresh token
      #  - if fails, get new auth token

      d = get_account_info

      if !d
        logger.debug "authenticate: first failed, using refresh token"
        get_refresh_token
        d = get_account_info

        if !d
          logger.debug "authenticate: fell back to getting new token"
          get_auth_token
        else
          logger.debug "authenticate: good on second try after refresh token"
          return true
        end
      else
        logger.debug "authenticate: all good from the start."
        return true
      end
    end
  end



  def get_auth_token(type='password')
    a = {
      'grant_type': type,
      'client_id': @client_id,
      'client_secret': @client_secret
    }

    if type == 'password'
      a["username"] = @username
      a["password"] = @password
    elsif type == 'refresh_token'
      a["refresh_token"] = @refresh_token
    end

    # get it
    d = send_request('/token', a)
    logger.debug "get_auth_token: #{type} -- resp: #{d.inspect}"
    
    # save it
    @access_token = d["access_token"]
    @refresh_token = d["refresh_token"]
    Setting.set('act_on_refresh_token', @refresh_token)
    Setting.set('act_on_access_token', @access_token)
  end



  def get_refresh_token
    get_auth_token('refresh_token');
  end


  def get_lists
    return get_request('/api/1/list?listingtype=CONTACT_LIST')
  end



  def get_account_info
    return get_request('/api/1/account');
  end



  def update_list(list_id, users)

    a = {
      'headings': "Y",
      'fieldseparator': "COMMA",
      'quotecharacter': "NONE",
      'listId': list_id
    }

    up_specs = [
      {
        "columnHeading": "Email",
        "ignoreColumn": "N",
        "columnIndex": 0,
        "columnType": "EMAIL"
      },
      {
        "columnHeading": "First Name",
        "ignoreColumn": "N",
        "columnIndex": 1
      },
      {
        "columnHeading": "Last Name",
        "ignoreColumn": "N",
        "columnIndex": 2
      },
      {
         "columnHeading" => "Company",
         "ignoreColumn" => "N",
         "columnIndex" => 3
      }
    ]
    a['uploadspecs'] = up_specs.to_json
    a['mergespecs']='[{"dstListId":"'+list_id.to_s+'","mergeMode":"UPSERT","columnMap":[]}]]'
     

    file_path = create_user_csv(users)
    a['file'] = Faraday::UploadIO.new(file_path, 'text/csv')

    path = "/api/1/list/#{list_id}"
    logger.debug "update_list sending #{path} -- #{a.inspect}"
    
    conn2 = Faraday.new(:url => CONFIG["act_on_api"]["host"]) do |faraday|
      faraday.request  :multipart               
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    resp = conn2.put do |req|
      req.url path
      req.headers["Authorization"] = "Bearer #{@access_token}"
      req.headers["Cache-Control"] = "no-cache"
      req.headers["Content-Type"]  = "multipart/form-data"
      req.body = a
    end

    d = JSON.parse( resp.body )
    logger.info "update_list resp: -- #{d.inspect}"
    return d
  end



  def create_user_csv( users )
    Dir.mkdir('tmp') unless File.exist?('tmp')

    file_path = 'tmp/user_upload.csv'

    CSV.open(file_path, "wb") do |csv|
      csv << ["Email","First Name","Last Name"]
      users.each do |u|
        csv << [u["email"], u["first_name"], u["last_name"],u["company"]]
      end
    end
    return file_path
  end


  def sync_webinar( w, users )

    d = get_lists
    logger.debug "get_lists resp:\n #{d.inspect}"

    # figure out list based on campaign id
    list_id = false;
    d["result"].each do |l|
      if l["id"].include?(w.campaign_id)
        list_id = l["id"]
        logger.debug "Found List to use: #{list_id}"
        break
      end
    end

    return false if !list_id # couldn't find it
    
    # send users to the right list
    return update_list(list_id, users)
  end

end