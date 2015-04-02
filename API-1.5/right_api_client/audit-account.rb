#!/usr/bin/env ruby

require 'rubygems'
require 'right_api_client'



# Primary Inputs
email = ENV['rs_email'] || 'your@email.com'          # RS User Account
pass = ENV['rs_pswd'] || 'yourpassword'              # RS User Password
acct_id = ENV['rs_acct'] || '12345'                  # RS Account to backup scripts from


# Optional Inputs
timeout = ENV['rs_timeout'] || 60                    # Timeout in Seconds


puts ENV.has_key?('rs_email') ? 'rs_email set by ENVIRONMENT' : 'rs_email set by SCRIPT [default]'
puts ENV.has_key?('rs_pswd') ? 'rs_pswd set by ENVIRONMENT' : 'rs_pswd set by SCRIPT [default]'
puts ENV.has_key?('rs_acct') ? 'rs_acct set by ENVIRONMENT' : 'rs_acct set by SCRIPT [default]'


# Authenticate
@client = RightApi::Client.new(:email => email, :password => pass, :account_id => acct_id, :timeout => timeout.to_i )

puts "Authenticated!"

puts "Auditing RightScale Account: #{acct_id}"

File.open('audit.csv', 'w') do |f|
  f.puts '"deployment_name","server_type","instance_lineage","instance_name","instance_type","instance_datacenter","instance_state"'
    @client.deployments.index.each do |deployment|

      deployment_name=deployment.name

      # Query all Servers in deployment
      deployment.servers.index.each do |server|
        server_type='server'

        if defined? server.show.current_instance == "method"
          instance_lineage='current'
          instance_name=server.show.current_instance.show(:view => "extended").name.to_s
          instance_state=server.show.current_instance.show(:view => "extended").state.to_s
          instance_datacenter=server.show.current_instance.show(:view =>'extended').datacenter.show.name.to_s
          instance_type=''
          if defined? server.show.current_instance.show(:view => "extended").instance_type == "method"
            instance_type=server.show.current_instance.show(:view => "extended").instance_type.show.name.to_s
          end
          f.puts "\"#{deployment_name}\",\"#{server_type}\",\"#{instance_lineage}\",\"#{instance_name}\",\"#{instance_type}\",\"#{instance_datacenter}\",\"#{instance_state}\""

        else #else current_instance does not exist.. will audit next instance
          instance_lineage='next'
          instance_name=server.show.next_instance.show.name.to_s
          instance_state=server.show.next_instance.show(:view => "extended").state.to_s
          instance_datacenter=server.show.next_instance.show(:view => "extended").cloud.show.name.to_s
          instance_type=''
          if defined? server.show.next_instance.show(:view => "extended").instance_type == "method"
            instance_type=server.show.next_instance.show(:view => "extended").instance_type.show.name.to_s
          end
          f.puts "\"#{deployment_name}\",\"#{server_type}\",\"#{instance_lineage}\",\"#{instance_name}\",\"#{instance_type}\",\"#{instance_datacenter}\",\"#{instance_state}\""

        end #end if current_instances
      end #end servers.each



      # Query all ServerArrays in deployment
      deployment.server_arrays.index.each do |sa|
        server_type='array'
        if sa.show.current_instances.index.count > 0

          sa.show.current_instances.index(:view => 'extended').each do |instance|
            instance_lineage='current'
            instance_name=instance.show(:view => "extended").name.to_s
            instance_state=instance.show(:view => "extended").state.to_s
            instance_datacenter=instance.show(:view =>'extended').cloud.show.name.to_s
            instance_type=''
            if defined? instance.show(:view => "extended").instance_type == "method"
              instance_type=instance.instance_type.show.name.to_s
            end
            f.puts "\"#{deployment_name}\",\"#{server_type}\",\"#{instance_lineage}\",\"#{instance_name}\",\"#{instance_type}\",\"#{instance_datacenter}\",\"#{instance_state}\""
          end
        else
          instance_lineage='next'
          instance_name=sa.next_instance.show(:view => "extended").name.to_s
          instance_state=sa.next_instance.show(:view => "extended").state.to_s
          instance_datacenter=sa.next_instance.show(:view =>'extended').cloud.show.name.to_s
          instance_type=''
          if defined? sa.next_instance.show(:view => "extended").instance_type == "method"
            instance_type=sa.next_instance.show(:view => "extended").instance_type.show.name.to_s
          end
          f.puts "\"#{deployment_name}\",\"#{server_type}\",\"#{instance_lineage}\",\"#{instance_name}\",\"#{instance_type}\",\"#{instance_datacenter}\",\"#{instance_state}\""

        end #end if count==0
      end#end server_arrays.each


    end #end deployments.each
end #end File.open
