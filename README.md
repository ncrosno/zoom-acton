# Zoom-ActOn

A simple ruby app to map webinar info from Zoom.us to Act-On/Salesforce.

- Stores lists of webinars with associated Salesforce Campaign IDs.
- Syncs webinar users to their associated Act-On user Lists based on Campaign ID

Setup:
- Update config/config.yml
- `bundle install`
- `rake db:migrate`
- Create an API User with `rake create_user`

Run The Web App:
- Run the sinatra app to accept API calls
   `ruby server.rb`

Save new Webinar+Campaign combos via API:
  ```
  curl http://127.0.0.1:4567/webinar/create -F api_key=YOUR-KEY -F campaign_id=123abc456def -F webinar_id=999-888-777
  ```

Sync data between Zoom and ActOn
- `rake sync_webinars`