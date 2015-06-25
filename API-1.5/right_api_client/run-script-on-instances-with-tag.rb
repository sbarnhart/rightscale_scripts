#!/usr/bin/env ruby

require 'rubygems'
require 'right_api_client'



# Primary Inputs
email = ENV['rs_email'] || 'your@email.com'          # RS User Account
pass = ENV['rs_pswd'] || 'yourpassword'              # RS User Password
acct_id = ENV['rs_acct'] || '12345'                  # RS Account

script_href = ENV['rs_script'] || '/api/right_scripts/543220003'	# RightScript to run (HREF)
tags = ENV['rs_tags'] || 'my:instance=yes'							# Tag to search for and run script on


# Optional Inputs
timeout = ENV['rs_timeout'] || 600                    				# Timeout in Seconds



puts ENV.has_key?('rs_email') ? 'rs_email set by ENVIRONMENT' : 'rs_email set by SCRIPT [default]'
puts ENV.has_key?('rs_pswd') ? 'rs_pswd set by ENVIRONMENT' : 'rs_pswd set by SCRIPT [default]'
puts ENV.has_key?('rs_acct') ? 'rs_acct set by ENVIRONMENT' : 'rs_acct set by SCRIPT [default]'


# Authenticate
@client = RightApi::Client.new(:email => email, :password => pass, :account_id => acct_id, :timeout => timeout.to_i )

# Query API for all instances with tag
found_tags=@client.tags.by_tag(:resource_type => 'instances', :tags => [tags])

if found_tags.count > 0 
	puts "Found #{found_tags.count} tag(s)!"
else
	abort("No instances found with tag: '"+tags+"'")	
end

# Only 1 tag should be returned per unique tag found (as resource_tag object).
# This will contain all the instances/resources that contain that tag.
if @client.tags.by_tag(:resource_type => 'instances', :tags => [tags]).first.show.resource.is_a? Array
	instances=@client.tags.by_tag(:resource_type => 'instances', :tags => [tags]).first.show.resource
else
	instances=[@client.tags.by_tag(:resource_type => 'instances', :tags => [tags]).first.show.resource]
end


tasks=[]
# Loop through the instances and trigger the script to run on each
instances.each do |instance|
	# run_executable will return a task object which can be used to monitor the status of the task
	task=instance.show.run_executable(:right_script_href => script_href)
	tasks.insert(0, task)
	puts "Task schedule on #{instance.show.name} (#{instance.show.href})"
end

puts ""
# Let's loop through tasks and monitor them until they are all complete
puts "Monitoring status until all tasks are finished.  Tasks scheduled: #{tasks.count}"
while tasks.count > 0 do
	tasks.each do |task|
		if task.show.summary.include? "completed: "
			puts "Task completed! [#{task.show.href}]"
			tasks.delete_at(tasks.index(task)) 
		end
	end
	puts "Tasks remaining: #{tasks.count}"
	sleep(15)
end

puts 'Finished!'