#!/usr/bin/env ruby

require 'rubygems'
require 'right_api_client'
require 'irb'


# Primary Inputs
email = ENV['rs_email'] || 'your@email.com'          # RS User Account
pass = ENV['rs_pswd'] || 'yourpassword'              # RS User Password
acct_id = ENV['rs_acct'] || '12345'                  # RS Account to login to


# Optional Inputs
timeout = ENV['rs_timeout'] || 600                    # Timeout in Seconds


puts ENV.has_key?('rs_email') ? 'rs_email set by ENVIRONMENT' : 'rs_email set by SCRIPT [default]'
puts ENV.has_key?('rs_pswd') ? 'rs_pswd set by ENVIRONMENT' : 'rs_pswd set by SCRIPT [default]'
puts ENV.has_key?('rs_acct') ? 'rs_acct set by ENVIRONMENT' : 'rs_acct set by SCRIPT [default]'


# Authenticate
@client = RightApi::Client.new(:email => email, :password => pass, :account_id => acct_id, :timeout => timeout.to_i )

puts "Authenticated!"

puts "The RightAPI::Client object is @client.  Starting IRB console......"
puts "Type `exit` to terminate the console and return to the shell prompt."

IRB.start
