echo -n "Enter your password:"
read passwd
./env_pre.sh --dev tara --passwd $passwd
./run_test.sh --config tara.config
