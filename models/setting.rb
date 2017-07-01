# For generic dynamic storage that cannot be added to config.yml
class Setting < ActiveRecord::Base

  def self.get(k)
    Setting.find_by(key: k).val
  end

  def self.set(k, v)
    s = Setting.find_or_initialize_by(key: k)
    s.val = v
    s.save
  end
  
end