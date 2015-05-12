#!/bin/bash
currDir=`pwd`
currTimestamp=`date +%s`
# Clone the repo
git clone --depth 1 https://github.com/rightscale/docs /tmp/rs-docs-$currTimestamp/
cd "/tmp/rs-docs-$currTimestamp"
echo '[rs-docs-edit-statusPage] Opening new branch'
git checkout -b "edit-statusPage-$currTimestamp"
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
echo "[rs-docs-edit-statusPage] Platform detected: $platform. Launching editor"
### Open the browser
if [[ $platform == 'linux' ]]; then
  xdg-open "/tmp/rs-docs-$currTimestamp/source/status.html.md" &> /dev/null
  xdg-open "http://localhost:4567/status.html" &> /dev/null
elif [[ $platform == 'osx' ]]; then
  open "/tmp/rs-docs-$currTimestamp/source/status.html.md" &> /dev/null
  open "http://localhost:4567/status.html" &> /dev/null
fi
echo "[rs-docs-edit-statusPage] Starting MiddleMan Server.  Hit CTRL+C when finished."
bundle exec middleman server > /dev/null

while true; do
    read -p "[rs-docs-edit-statusPage] Would you like to commit your changes [yes/no]? " yn
    case $yn in
        [Yy]* ) git commit -a; break;;
        [Nn]* ) echo "[rs-docs-edit-statusPage] All done -- exiting script"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


while true; do
    read -p "[rs-docs-edit-statusPage] Would you like to push your changes to GitHub [yes/no]? " yn
    case $yn in
        [Yy]* ) git push --all; break;;
        [Nn]* ) echo "[rs-docs-edit-statusPage] All done -- exiting script"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
