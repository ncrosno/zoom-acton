# Zoom-ActOn

A simple ruby app to map webinar info from Zoom.us to Act-On/Salesforce.

- Stores lists of webinars with associated Salesforce Campaign IDs.
- Syncs webinar users to their associated Act-On user Lists based on Campaign ID

Setup:
- Update config/config.yml
- bundle install
- rake db:migrate
- Create an API User with `rake create_user`

To Run:
- Add [TBD] script to the crontab.
- Run the sinatra app to accept API calls
   `ruby server.rb`

