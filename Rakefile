require './server'
require 'sinatra/activerecord/rake'

task :create_user do
  email = ''
  STDOUT.puts "Enter the email of the new user:"
  email = STDIN.gets.chomp
  
  raise "bah, humbug!" if email.blank?

  puts ApiUser.add(email)
end


task :get_key do
  email = ''
  STDOUT.puts "Enter the email of the user:"
  email = STDIN.gets.chomp
  
  raise "bah, humbug!" if email.blank?

  u = ApiUser.find_by(email: email)
  puts u ? u.api_key : "User not found"
end