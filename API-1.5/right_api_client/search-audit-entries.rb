#!/usr/bin/env ruby

require 'rubygems'
require 'right_api_client'


if ARGV.length == 0
  abort "No search text specified"
end

# Primary Inputs
email = ENV['rs_email'] || 'your@email.com'          # RS User Account
pass = ENV['rs_pswd'] || 'yourpassword'              # RS User Password
acct_id = ENV['rs_acct'] || '12345'                  # RS Account to backup scripts from


# Optional Inputs
timeout = ENV['rs_timeout'] || 60                    # Timeout in Seconds


#puts "Search account #{acct_id} for: "
#search_text = gets.strip
search_text = ARGV.join(' ')
time = Time.new
time = time - 7948800
search_startDate = time.strftime('%Y/%m/%d 00:00:00 +0000')
time = Time.new
search_endDate = time.strftime('%Y/%m/%d %H:%M:%S +0000')
puts "Searching for \"#{search_text}\" in audit entries from [#{search_startDate}] to [#{search_endDate}]"


# Authenticate
@client = RightApi::Client.new(:email => email, :password => pass, :account_id => acct_id, :timeout => timeout.to_i )

@client.audit_entries.index(:start_date => search_startDate, :end_date => search_endDate, :limit => '1000').each do |entry|
  if entry.show.detail.show.text.split(search_text).count > 1 then
    puts [entry.show.href,entry.show.detail.show.text]
    puts '-==========================================-'
  end
end
