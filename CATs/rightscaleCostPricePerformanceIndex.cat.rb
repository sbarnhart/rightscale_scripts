name 'RightScale Cost-Price-Performance Index'
rs_ca_ver 20131202
short_description 'Launch the RightScale Cost-Price-Performance Index CloudApp'

## User Parameters and Mappings


## MySQL DB Server Resource
resource 'cppi_mysql_db', type: 'server' do
  name 'CPPI MySQL DB Server [Database Manager for MySQL 5.5 (v13.5.7-LTS)]'
  cloud 'EC2 us-west-2'
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


## Override the 'autolaunch' operation with our own custom `launch_concurrent` operation
operation "launch" do
  definition "custom_launch"
end


## custom_launch operation Definition
define custom_launch(@cppi_mysql_db) do
  call launch_phase1(@cppi_mysql_db)
end

define launch_phase1(@cppi_mysql_db) task_label: "Setup MySQL DB" do
  provision(@cppi_mysql_db)
  @current_instance = @cppi_mysql_db.current_instance()
  @current_instance.run_executable(recipe_name: "db::do_init_and_become_master") #Initializes DB and sets DNS
  @current_instance.run_executable(recipe_name: "db::do_dump_import") #Imports mysqldump to DB
end
