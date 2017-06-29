class ApiUser < ActiveRecord::Base

  require 'securerandom'

  
  def generate_key
    self.api_key = SecureRandom.uuid
  end

  # Returns a string with info about the new user
  def self.add(email)
    
    u = ApiUser.find_by(email:email)
    return "User already exists" if u

    u = ApiUser.new(email: email)
    u.generate_key
    if u.save
      return "User created #{email} and key: #{u.api_key}"
    else
      return "An unknown error occurred."
    end

  end

end