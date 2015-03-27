#!/bin/bash -e


email=${rs_email:='your@email.com'}     # RS User Account
pass=${rs_pswd:='yourpassword'}         # RS User Password


if [ -z "$1" ]; then
  echo
  echo -n "Please enter the RS Account ID you wish to observe: "
  read acct_id
  exit
else
  acct_id=$1
fi


### Authenticate and get cookie for MASTER account ###
# Pre-configure MASTER account ID (60072)
account_href="/api/accounts/60072"
# Execute API Call to retrieve cookie and save it to mycookie
curl -s -H X_API_VERSION:1.5 -c mycookie \
-d email="$email" \
-d password="$pass" \
-d account_href="$account_href" \
-X POST https://my.rightscale.com/api/session


customer_acct=$acct_id
# Use cookie to authenticate and observe account
### Execute API Call to retrieve cookie and save it to mycookie
curl --silent -H X_API_VERSION:1.5 -b mycookie \
-d Host="us-3.rightscale.com" \
-d Referer="https://us-3.rightscale.com/global//admin_accounts/$customer_acct" \
-X POST https://us-3.rightscale.com/global//admin_accounts/$customer_acct/access &> /dev/null

# Open the account page in the browser
### Find out what OS we are running on so we can launch the browser properly
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
  platform='freebsd'
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='osx'
fi
echo
echo "[observe-account] Platform detected: $platform."
### Open the browser
if [[ $platform == 'linux' ]]; then
  xdg-open "https://my.rightscale.com/acct/$customer_acct" &> /dev/null
elif [[ $platform == 'osx' ]]; then
  open "https://my.rightscale.com/acct/$customer_acct" &> /dev/null
fi
echo "[observe-account] Browser launched!"
echo
