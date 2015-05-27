#!/bin/bash -e


email=${rs_email:='your@email.com'}     # RS User Account
pass=${rs_pswd:='yourpassword'}         # RS User Password


if [ -z "$1" ]; then
  echo
  echo -n "Please enter the RS Account ID to access the RightScript: "
  read acct_id
else
  acct_id=$1
fi

if [ -z "$2" ]; then
  echo
  echo -n "Please enter the RightScript ID you wish to update: "
  read rightscript_id
else
  rightscript_id=$2
fi

if [ -z "$3" ]; then
  echo
  echo -n "Please enter the full path to the source file you wish to update the RightScript ($rightscript_id) with: "
  read source_file
else
  source_file=$3
fi


### Authenticate and get cookie for RS account ###
account_href="/api/accounts/$acct_id"
# Execute API Call to retrieve cookie and save it to mycookie
curl -l -H X_API_VERSION:1.5 -c mycookie \
  -d email="$email" \
  -d password="$pass" \
  -d account_href="$account_href" \
  -X POST https://my.rightscale.com/api/session

curl -l -H X_API_VERSION:1.5 -b mycookie \
  --upload-file $source_file \
  -X PUT https://my.rightscale.com/api/right_scripts/$rightscript_id/source