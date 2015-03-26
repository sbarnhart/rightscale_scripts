#!/usr/bin/env ruby

require 'rubygems'
require 'right_api_client'
require 'irb'

email = ENV['rs_email'] || 'your@email.com'     # RS User Account
pass = ENV['rs_pswd'] || 'yourpassword'         # RS User Password
acct_id = ENV['rs_acct'] || '12345'             # RS Account to Backup
timeout = ENV['rs_timeout'].to_i || 60          # Timeout in Seconds


# Authenticate
@client = RightApi::Client.new(:email => email, :password => pass, :account_id => acct_id, :timeout => timeout)
puts "Authentication successful!  The RightAPI::Client object is @client"
puts "Starting IRB console.  Type `exit` to terminate the console and return to the shell prompt."

IRB.start
