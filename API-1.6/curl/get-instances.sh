#!/bin/bash -e


email=${rs_email:='your@email.com'}     # RS User Account
pass=${rs_pswd:='yourpassword'}         # RS User Password
acct_id=${rs_acct:='12345'}             # RS Account ID

# Authenticate using API 1.5
curl -H X_API_VERSION:1.5 -c mycookie \
--data-urlencode "email=$email" \
--data-urlencode "password=$pass" \
-d account_href="/api/accounts/$acct_id" \
-X POST https://my.rightscale.com/api/session

# Use API 1.6 to get all instances
curl -i -H X-API-VERSION:1.6 -H X-Account:$acct_id -b mycookie -X GET https://my.rightscale.com/api/instances
