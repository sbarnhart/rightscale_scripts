#!/usr/bin/env ruby

require 'rubygems'
require 'right_api_client'
require 'pp'



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

@client.deployments.index(:filter => ['name==bk.']).each do |deployment|

  puts "DEPLOYMENT:  #{deployment.name}"

  deployment.servers.index.each do |server|
    # pp server.methods:
    # [:links, :launch, :clone, :deployment, :next_instance, :alert_specs, :alerts, :created_at, :state, :updated_at, :description, :name, :href, :destroy,     :update, :show, :client, :attributes, :associations, :actions, :raw, :resource_type, :inspect, :[], :method_missing, :define_instance_method, :api_methods, :get_associated_resources, :has_id, :add_id_and_params_to_path, :insert_in_path, :is_singular?, :get_href_from_links, :get_and_delete_href_from_links, :simple_singularize, :get_singular, :fix_array_of_hashes, :pretty_print, :pretty_print_cycle, :pretty_print_instance_variables, :pretty_print_inspect, :to_json, :nil?, :===, :=~, :!~, :eql?, :hash, :<=>, :class, :singleton_class, :dup, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :freeze, :frozen?, :to_s, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :remove_instance_variable, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :extend, :display, :method, :public_method, :define_singleton_method, :object_id, :to_enum, :enum_for, :pretty_inspect, :==, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__]
    #
    # pp server.api_methods
    # [:links, :launch, :clone, :deployment, :next_instance, :alert_specs, :alerts, :created_at, :state, :updated_at, :description, :name, :href, :destroy, :update, :show]

    if defined? server.show.current_instance == "method"
      puts "Current Instance"
      #puts "Current Instance Type: #{server.show.current_instance.show(:view => "extended").instance_type.show.name}"
    else
      puts "Next Instance"
      #puts "Next Instance Type: #{server.show.next_instance.show(:view => "extended").instance_type.show.name}"
    end

  end

  deployment.server_arrays.index.each do |sa|

  end

end
