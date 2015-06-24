#!/bin/bash -e


email=${rs_email:='your@email.com'}     # RS User Account
pass=${rs_pswd:='yourpassword'}         # RS User Password
acct_id=${rs_acct:='12345'}             # RS Account ID

echo "Authenticating and retrieving cookie for $email @ $acct_id.  Saving cookie to file 'mycookie'"

### Execute API Call to retrieve cookie and save it to mycookie
account_href="/api/accounts/$acct_id"
curl -l -i -H X_API_VERSION:1.5 -c mycookie \
-d email="$email" \
-d password="$pass" \
-d account_href="$account_href" \
-X POST https://my.rightscale.com/api/session
