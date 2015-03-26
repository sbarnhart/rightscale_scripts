#!/bin/bash -e


email=${rs_email:='your@email.com'}     # RS User Account
pass=${rs_pswd:='yourpassword'}         # RS User Password
acct_id=${rs_acct:='12345'}             # RS Account ID


if [ $# -ne "1" ]; then
  echo "Usage:  3tier ServerNamePrefix"
  echo "ServerNamePrefix will get prepended to all created servers"
  echo "Exiting . . ."
  exit 0
fi



### Execute API Call to retrieve cookie and save it to mycookie
echo "Authenticating and retrieving cookie for $email @ $acct_id.  Saving cookie to file 'mycookie'"
account_href="/api/accounts/$acct_id"
curl -i -H X_API_VERSION:1.5 -c mycookie \
-d email="$email" \
-d password="$pass" \
-d account_href="$account_href" \
-X POST https://my.rightscale.com/api/session

pwd=`pwd`

## STEP 2 - CREATE DEPLOYMENT AND SERVERS (2 LB, 2 APP, 2 DB)
# CONFIGURATION
echo "Reading configuration files . . . "
read CLOUD DEPLOYMENT SG SSH_KEY < $pwd"/configs/generic.cfg"
read ST_LB MCI_LB ITYPE_LB ST_APP MCI_APP ITYPE_APP ST_DB MCI_DB ITYPE_DB < $pwd"/configs/3tier.cfg"
echo
echo "Done (config)"
echo "Values set: $ST_LB $MCI_LB $ITYPE_LB $ST_APP $MCI_APP $ITYPE_APP $ST_DB $MCI_DB $ITYPE_DB"
echo

# Create Load Balancers
echo "Create Load Balancer #1"
curl -i -H X_API_VERSION:1.5 -b mycookie -X POST \
-d server[name]=$1_load_balancer1 \
-d server[description]=$1_load_balancer1 \
-d server[deployment_href]=/api/deployments/$DEPLOYMENT \
-d server[instance][cloud_href]=/api/clouds/$CLOUD \
-d server[instance][server_template_href]=/api/server_templates/$ST_LB \
-d server[instance][multi_cloud_image_href]=/api/multi_cloud_images/$MCI_LB \
-d server[instance][instance_type_href]=/api/clouds/$CLOUD/instance_types/$ITYPE_LB \
-d server[instance][security_group_hrefs][]=/api/clouds/$CLOUD/security_groups/$SG \
-d server[instance][ssh_key_href]=/api/clouds/$CLOUD/ssh_keys/$SSH_KEY \
https://my.rightscale.com/api/servers
echo "Done (load bal 1)"
echo

echo "Create Load Balancer #2"
curl -i -H X_API_VERSION:1.5 -b mycookie -X POST \
-d server[name]=$1_load_balancer2 \
-d server[description]=$1_load_balancer2 \
-d server[deployment_href]=/api/deployments/$DEPLOYMENT \
-d server[instance][cloud_href]=/api/clouds/$CLOUD \
-d server[instance][server_template_href]=/api/server_templates/$ST_LB \
-d server[instance][multi_cloud_image_href]=/api/multi_cloud_images/$MCI_LB \
-d server[instance][instance_type_href]=/api/clouds/$CLOUD/instance_types/$ITYPE_LB \
-d server[instance][security_group_hrefs][]=/api/clouds/$CLOUD/security_groups/$SG \
-d server[instance][ssh_key_href]=/api/clouds/$CLOUD/ssh_keys/$SSH_KEY \
https://my.rightscale.com/api/servers
echo "Done (load bal 2)"
echo

echo "Create App Server #1"
curl -i -H X_API_VERSION:1.5 -b mycookie -X POST \
-d server[name]=$1_app_server1 \
-d server[description]=$1_app_server1 \
-d server[deployment_href]=/api/deployments/$DEPLOYMENT \
-d server[instance][cloud_href]=/api/clouds/$CLOUD \
-d server[instance][server_template_href]=/api/server_templates/$ST_APP \
-d server[instance][multi_cloud_image_href]=/api/multi_cloud_images/$MCI_APP \
-d server[instance][instance_type_href]=/api/clouds/$CLOUD/instance_types/$ITYPE_APP \
-d server[instance][security_group_hrefs][]=/api/clouds/$CLOUD/security_groups/$SG \
-d server[instance][ssh_key_href]=/api/clouds/$CLOUD/ssh_keys/$SSH_KEY \
https://my.rightscale.com/api/servers
echo "Done (app server 1)"
echo

echo "Create App Server #2"
curl -i -H X_API_VERSION:1.5 -b mycookie -X POST \
-d server[name]=$1_app_server2 \
-d server[description]=$1_app_server2 \
-d server[deployment_href]=/api/deployments/$DEPLOYMENT \
-d server[instance][cloud_href]=/api/clouds/$CLOUD \
-d server[instance][server_template_href]=/api/server_templates/$ST_APP \
-d server[instance][multi_cloud_image_href]=/api/multi_cloud_images/$MCI_APP \
-d server[instance][instance_type_href]=/api/clouds/$CLOUD/instance_types/$ITYPE_APP \
-d server[instance][security_group_hrefs][]=/api/clouds/$CLOUD/security_groups/$SG \
-d server[instance][ssh_key_href]=/api/clouds/$CLOUD/ssh_keys/$SSH_KEY \
https://my.rightscale.com/api/servers
echo "Done (app server 2)"
echo

echo "Create DB Server #1"
curl -i -H X_API_VERSION:1.5 -b mycookie -X POST \
-d server[name]=$1_db_server1 \
-d server[description]=$1_db_server1 \
-d server[deployment_href]=/api/deployments/$DEPLOYMENT \
-d server[instance][cloud_href]=/api/clouds/$CLOUD \
-d server[instance][server_template_href]=/api/server_templates/$ST_DB \
-d server[instance][multi_cloud_image_href]=/api/multi_cloud_images/$MCI_DB \
-d server[instance][instance_type_href]=/api/clouds/$CLOUD/instance_types/$ITYPE_DB \
-d server[instance][security_group_hrefs][]=/api/clouds/$CLOUD/security_groups/$SG \
-d server[instance][ssh_key_href]=/api/clouds/$CLOUD/ssh_keys/$SSH_KEY \
https://my.rightscale.com/api/servers
echo "Done (db server #1)"
echo

echo "Create DB Server #2"
curl -i -H X_API_VERSION:1.5 -b mycookie -X POST \
-d server[name]=$1_db_server2 \
-d server[description]=$1_db_server2 \
-d server[deployment_href]=/api/deployments/$DEPLOYMENT \
-d server[instance][cloud_href]=/api/clouds/$CLOUD \
-d server[instance][server_template_href]=/api/server_templates/$ST_DB \
-d server[instance][multi_cloud_image_href]=/api/multi_cloud_images/$MCI_DB \
-d server[instance][instance_type_href]=/api/clouds/$CLOUD/instance_types/$ITYPE_DB \
-d server[instance][security_group_hrefs][]=/api/clouds/$CLOUD/security_groups/$SG \
-d server[instance][ssh_key_href]=/api/clouds/$CLOUD/ssh_keys/$SSH_KEY \
https://my.rightscale.com/api/servers
echo "Done (db server #2)"
echo

echo "Setting Inputs for 3 Tier Deployment with PHP App Server"
## Master-DB Required Inputs
curl -i -H X_API_VERSION:1.5 -b mycookie \
-d inputs[][name]="rightscale/timezone" \
-d inputs[][value]="text:US/Pacific" \
-d inputs[][name]="db/backup/lineage" \
-d inputs[][value]="bk_test_lineage" \
-d inputs[][name]="db/dns/master/fqdn" \
-d inputs[][value]="db1.rightscale.bryankaraffa.com" \
-d inputs[][name]="sys_dns/choice" \
-d inputs[][value]="text:DNSMAdeEasy" \
-d inputs[][name]="sys_dns/user" \
-d inputs[][value]="cred:BK_DNS_USER" \
-d inputs[][name]="sys_dns/password" \
-d inputs[][value]="cred:BK_DNS_PASSWORD" \
-d inputs[][name]="db/dns/master/id" \
-d inputs[][value]="cred:BK_DNS_DB1_ID" \
-X PUT https://my.rightscale.com/api/deployments/$DEPLOYMENT/inputs/multi_update

## Get Server IDs for the newly created servers
curl -i -H X_API_VERSION:1.5 -b mycookie -o tmp \
-d filter[]="deployment_href==/api/deployments/$DEPLOYMENT" \
-d filter[]="name==$1_db_server1" \
-X GET https://my.rightscale.com/api/servers.xml
## Parse server ID from server
tmp=`grep "<link rel=\"self\"" tmp` && tmp=${tmp//<link rel=\"self\" href=\"\/api\/servers\//''} && tmp=${tmp//\"\/>/''} && tmp=${tmp//' '/''}
DB1_ID=$tmp


echo
echo
echo
cat tmp
echo
echo
echo
## Launch DB1 Server
echo "Launching DB1 - [API Call: https://my.rightscale.com/api/servers/$DB1_ID/launch ]"
curl -i -H X_API_VERSION:1.5 -b mycookie -X POST https://my.rightscale.com/api/servers/$DB1_ID/launch
echo 'DB1 Launched'
echo


## Get DB1 Current Instance ID
curl -i -H X_API_VERSION:1.5 -b mycookie -o tmp \
-d filter[]="deployment_href==/api/deployments/$DEPLOYMENT" \
-d filter[]="name==$1_db_server1" \
-X GET https://my.rightscale.com/api/servers.xml
## Parse instance ID from server
tmp=`grep "current_instance" tmp` && tmp=${tmp//<link rel=\"current_instance\" href=\"\/api\/clouds\/$CLOUD\/instances\/''} && tmp=${tmp//\"\/>/''} && tmp=${tmp//' '/''}
DB1_INSTANCE=$tmp

## Execute db::init_and_become_master
echo "Executing db::init_and_become_master [ API Call: https://my.rightscale.com/api/clouds/$CLOUD/instances/$DB1_INSTANCE/run_executable ]"
RIGHTSCRIPT="3706444003"        # RightScript ID to run.  Can get this from the API or the UI/URL.
curl -i -H X_API_VERSION:1.5 -b mycookie -X POST \
-d recipe_name="db::do_init_and_become_master" \
https://my.rightscale.com/api/clouds/$CLOUD/instances/$DB1_INSTANCE/run_executable

#cleanup
rm -f mycookie tmp

echo
echo "Done (setting inputs)"
