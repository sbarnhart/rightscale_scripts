name 'RightScale Cost-Price-Performance Index'
rs_ca_ver 20131202
short_description 'Launch the RightScale Cost-Price-Performance Index CloudApp'
# CAT Developed by: Bryan Karaffa (April 2015)

## User Parameters and Mappings
parameter "cppi_instance_type" do
  type "string"
  label "Instance Type"
  description "Instance types comprise varying combinations of CPU, memory, storage, and networking capacity to fit different use cases.  There are General Purpose (t,m), Compute Optimized (c), Memory Optimized (r), GPU Optimized (g), and Storage Optimized (i,d) instance types."
  # Invalid allowed_values: t2.micro, r3.large will not work for this CloudApp
  # Tested allowed_values: m1.small, c3.large
  allowed_values "t2.small", "t2.medium", "m1.small", "m3.medium", "m3.large", "m3.xlarge", "m3.2xlarge", "c4.large", "c4.xlarge", "c4.2xlarge", "c4.4xlarge", "c4.8xlarge", "c3.large", "c3.xlarge", "c3.2xlarge", "c3.4xlarge", "c3.8xlarge", "g2.2xlarge", "g2.8xlarge", "r3.xlarge", "r3.2xlarge", "r3.4xlarge", "r3.8xlarge", "i2.xlarge", "i2.2xlarge", "i2.4xlarge", "i2.8xlarge", "d2.xlarge", "d2.2xlarge", "d2.4xlarge", "d2.8xlarge"
  default "m1.small"
end


## MySQL DB Server Resource
resource 'cppi_mysql_db_server', type: 'server' do
  name 'CPPI MySQL DB Server [Database Manager for MySQL 5.5 (v13.5.7-LTS)]'
  cloud 'EC2 us-west-2'
  instance_type $cppi_instance_type
  multi_cloud_image find('RightImage_CentOS_6.5_x64_v13.5_LTS', revision: 11)
  ssh_key 'default'
  security_groups 'monkey_private_ports_open'
  ## ServerTemplate - Use 'ALERTS-DISABLED' version for dev and debugging
  #server_template find('Database Manager for MySQL 5.5 (v13.5.7-LTS)', revision: 28) # RS Published DB Manager for MySQL 5.5 ST
  server_template find('ALERTS-DISABLED - Database Manager for MySQL 5.5 (v13.5.7-LTS)', revision: 1) # Cloned ST for dev and debugging
  inputs do {
    # BLOCK_DEVICE
    'block_device/devices/default/backup/secondary/cloud' => 'text:s3',
    'block_device/devices/default/backup/secondary/cred/secret' => 'cred:AWS_SECRET_ACCESS_KEY_PUBLISH',
    'block_device/devices/default/backup/secondary/cred/user' => 'cred:AWS_ACCESS_KEY_ID_PUBLISH',
    'block_device/devices/device1/backup/secondary/container' => 'text:wqa-discourse-backup',
    # DB / backup
    'db/backup/lineage' => 'text:test-backup-lineage-20140812',
    # DB / dns
    'db/dns/master/fqdn' => 'text:cppioregon.rightscale-services.com',
    'db/dns/master/id' => 'text:16985456', # cppioregon.rightscale-services.com <=> DNSMadeEasy Dynamic DNS ID: 16985456
    # DB / dump
    'db/dump/container' => 'text:cppi-app',
    'db/dump/database_name' => 'text:rsmarcomblog',
    'db/dump/prefix' => 'text:rsmarcomblog',
    'db/dump/storage_account_id' => 'cred:AWS_ACCESS_KEY_ID',
    'db/dump/storage_account_secret' => 'cred:AWS_SECRET_ACCESS_KEY',
    # SYS_DNS
    'sys_dns/choice' => 'text:DNSMadeEasy',
    'sys_dns/password' => 'cred:DNS_PASSWORD',
    'sys_dns/user' => 'cred:DNS_USER',
    # SYS_FIREWALL
    'sys_firewall/enabled' => 'text:disabled',
  } end
end


## Load Balancer Server Resource
resource 'cppi_loadbalancer_server1', type: 'server' do
  name 'CPPI Load Balancer #1 [Load Balancer with HAProxy (v13.5.5-LTS)]'
  cloud 'EC2 us-west-2'
  instance_type $cppi_instance_type
  multi_cloud_image find('RightImage_CentOS_6.5_x64_v13.5_LTS', revision: 11)
  ssh_key 'default'
  security_groups 'monkey_private_ports_open'
  ## ServerTemplate - Use 'ALERTS-DISABLED' version for dev and debugging
  #server_template find('Load Balancer with HAProxy (v13.5.5-LTS)', revision: 18)
  server_template find('ALERTS DISABLED - Load Balancer with HAProxy (v13.5.5-LTS)', revision: 1)
  inputs do {
    # LB
    'lb/health_check_uri' => 'text:/1e7cb78f-7a71-47fc-9d91-c0a9acf4dbc1.txt',
    'lb/session_stickiness' => 'text:false',
    # SYS_FIREWALL
    'sys_firewall/enabled' => 'text:disabled',
    # WEB_APACHE
    'web_apache/allow_override' => 'text:All',
  } end
end
resource 'cppi_loadbalancer_server2', type: 'server' do
  like @cppi_loadbalancer_server1
  name 'CPPI Load Balancer #2 [Load Balancer with HAProxy (v13.5.5-LTS)]'
end

## PHP App ServerArray Resource
resource 'cppi_app_serverarray', type: 'server_array' do
  name 'CPPI PHP App Servers [PHP App Server (v13.5.5-LTS)]'
  cloud 'EC2 us-west-2'
  instance_type $cppi_instance_type
  ssh_key 'default'
  security_groups 'default', 'monkey_private_ports_open'
  ## ServerTemplate - Use 'ALERTS-DISABLED' version for dev and debugging
  #server_template find('PHP App Server (v13.5.5-LTS) v1', revision: 0)
  server_template find('ALERTS-DISABLED - PHP App Server (v13.5.5-LTS) v1', revision: 0)
  inputs do {
    # APP
    'app/database_name' => 'text:rsmarcomblog',
    # APP_PHP
    'app_php/modules_list' => 'array:["text:php53u-mysql","text:php53u-gd","text:php53u-pdo","text:php53u-pecl-memcache","text:php53u-pecl-apc","text:php53u-xml","text:php53u-mbstring","text:php53u-pecl-imagick"]',
    # DB
    'db/dns/master/fqdn' => 'text:cppioregon.rightscale-services.com',
    'db/provider_type' => 'text:db_mysql_5.5',
    # REPO
    'repo/default/account' => 'cred:AWS_ACCESS_KEY_ID',
    'repo/default/credential' => 'cred:AWS_SECRET_ACCESS_KEY',
    'repo/default/prefix' => 'text:myapp731',
    'repo/default/provider' => 'text:repo_ros',
    'repo/default/repository' => 'text:cpp-app-use-inputs',
    'repo/default/storage_account_provider' => 'text:s3'
  } end
  state 'enabled'
  array_type 'alert'
  elasticity_params do {
    'bounds' => {
      'min_count'            => 2,
      'max_count'            => 20
    },
    'pacing' => {
      'resize_calm_time'     => 13,
      'resize_down_by'       => 1,
      'resize_up_by'         => 2
    },
    'alert_specific_params' => {
      'decision_threshold'   => 51
    }
  } end
end

## Outputs for CloudApp
output 'lb1_public_ip' do
  label "Front-End Server #1 URL"
  category "Info"
  default_value join(["Public URL: http://", @cppi_loadbalancer_server1.public_ip_address],"/")
  description "Front-End Server #1 Public IP"
end

output 'lb2_public_ip' do
  label "Front-End Server #2 URL"
  category "Info"
  default_value join(["Public URL: http://", @cppi_loadbalancer_server2.public_ip_address],"/")
  description "Front-End Server #2 Public IP"
end

output 'instance_type' do
  label 'Configuration'
  category 'Info'
  default_value $cppi_instance_type
  description "Instance type specified when launching this CloudApp"
end



## Override the 'autolaunch' operation with our own custom `launch_concurrent` operation
operation "launch" do
  definition "custom_launch"
end


## custom_launch Definition
define custom_launch(@cppi_mysql_db_server, @cppi_loadbalancer_server1, @cppi_loadbalancer_server2, @cppi_app_serverarray) return @cppi_mysql_db_server, @cppi_loadbalancer_server1, @cppi_loadbalancer_server2, @cppi_app_serverarray do
  concurrent return @cppi_mysql_db_server, @cppi_loadbalancer_server1, @cppi_loadbalancer_server2, @cppi_app_serverarray timeout: 120m, task_label: "Launching CPPI CloudApp" do

    ## Phase 1 - Setup and Deploy MySQL DB Server
    sub task_label: "Setup Database Server" do
      provision(@cppi_mysql_db_server)
      call run_recipe(@cppi_mysql_db_server, "db::do_init_and_become_master") #Initializes DB and sets DNS
      call run_recipe(@cppi_mysql_db_server, "db::do_dump_import") #Imports mysqldump to DB
    end
    ## End Phase 1

    ## Phase 2 - Setup and Deploy Load Balance Servers and App ServerArray
    # Provision LB1
    sub task_label: "Setup Front-End Server #1" do
      provision(@cppi_loadbalancer_server1)
    end
    # Provision LB2
    sub task_label: "Setup Front-End Server #2"  do
      provision(@cppi_loadbalancer_server2)
    end
    # Provision App ServerArray and attach to LoadBalancers
    sub task_label: "Setup App ServerArray" do
      provision(@cppi_app_serverarray)
      call multi_run_recipe(@cppi_app_serverarray, "app::do_loadbalancers_allow")
      call multi_run_recipe(@cppi_app_serverarray, "lb::do_attach_request")
    end
    ## End Phase 2

  end # End concurrent
end ## End custom_launch Definition


# Helper definition, runs a recipe on given resource, waits until recipe completes or fails
# Raises an error in case of failure
define run_recipe(@target, $recipe_name) do
  @task = @target.current_instance().run_executable(recipe_name: $recipe_name, inputs: {})
  sleep_until(@task.summary =~ "^(completed|failed)")
  if @task.summary =~ "failed"
    raise "Failed to run " + $recipe_name
  end
end
define multi_run_recipe(@target, $recipe_name) do
  @tasks = @target.current_instances().run_executable(recipe_name: $recipe_name, inputs: {})
  sleep_until(all?(@tasks.summary[], "/^(completed|failed)/"))
  if any?(@tasks.summary[], "/failed/")
    raise "Failed to run " + $recipe_name
  end
end
