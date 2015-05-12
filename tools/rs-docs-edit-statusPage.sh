#!/bin/bash
currDir=`pwd`
currTimestamp=`date +%s`
# Cleanup from previous runs
rm -rf /tmp/rs-docs-*/
# Clone the repo
git clone --depth 1 https://github.com/rightscale/docs /tmp/rs-docs-$currTimestamp/
cd "/tmp/rs-docs-$currTimestamp"
echo '[rs-docs-edit-statusPage] Creating new branch'
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
echo "[rs-docs-edit-statusPage] Platform detected: $platform."
### Set the openHandler to handle various OSes and input types (URLs, files, etc..)
if [[ $platform == 'linux' ]]; then
  openHandler='xdg-open';
elif [[ $platform == 'osx' ]]; then
  openHandler='open';
fi
echo "[rs-docs-edit-statusPage] Opening status.html.md in text editor and web browser (live reload)"
$openHandler "/tmp/rs-docs-$currTimestamp/source/status.html.md" &> /dev/null
$openHandler "http://localhost:4567/status.html" &> /dev/null
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
        [Yy]* ) git push --all; echo "[rs-docs-edit-statusPage] Opening Pull Request page GitHub.  Create a pull request and merge it to `master` to complete the process."; $openHandler "https://github.com/rightscale/docs/compare/edit-statusPage-$currTimestamp?expand=1"; break;;
        [Nn]* ) echo "[rs-docs-edit-statusPage] All done -- exiting script"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
