# For generic dynamic storage that cannot be added to config.yml
class Setting < ActiveRecord::Base

  def self.get(k)
    s = Setting.find_by(key: k)
    return s ? s.val : nil
  end

  def self.set(k, v)
    s = Setting.find_or_initialize_by(key: k)
    s.val = v
    s.save
  end
  
end