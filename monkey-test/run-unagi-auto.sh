#get passwd for flash.sh
echo -n "Enter your password:"
read -s passwd
echo

./env_pre.sh --dev unagi --passwd $passwd
./run_test.sh --config unagi.config
