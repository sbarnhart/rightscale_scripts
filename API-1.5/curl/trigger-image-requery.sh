#!/bin/bash -ex

auth_token=($(curl https://my.rightscale.com/session/new -s -l -i -c mycookie -H 'Origin: https://my.rightscale.com' -s -c mycookie | grep csrf-token | grep -o '\"[^"]*\"'))
auth_token=${auth_token[1]}
auth_token="${auth_token:1:${#auth_token}-2}"
echo "Authentication Token: $auth_token"
echo "Authenticating now"


curl 'https://my.rightscale.com/session' -H 'Origin: https://my.rightscale.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.81 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://my.rightscale.com/session/new' -H 'Connection: keep-alive' --data "authenticity_token=$auth_token&email=<THEUSERSEMAIL...YOUMIGHTKNOW>&password=<THEREALPASSWORD..YOUWILLNEVERKNOW>&sso_identifier=&commit=Log+In&login_type=rs" --compressed -c mycookie -s


echo 'Triggering requery'
curl 'https://us-3.rightscale.com/acct/7954/clouds/6/images/requery' -H 'Referer: https://us-3.rightscale.com/acct/7954/clouds/6/images' -H 'Origin: https://us-3.rightscale.com' -H 'Content-Type: application/x-www-form-urlencoded' --data "authenticity_token=$auth_token&_method=put" --compressed -s -b mycookie
