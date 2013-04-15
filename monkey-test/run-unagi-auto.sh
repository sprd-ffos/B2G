echo -n "Enter your password:"
read passwd
./env_pre.sh --dev unagi --passwd $passwd
./run_test.sh --config unagi.config
