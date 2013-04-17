#get passwd for flash.sh
echo -n "Enter your password:"
read -s passwd
echo

./env_pre.sh --dev mozilla_weekly_build_512x256_hvga --passwd $passwd
./run_test.sh --config tara.config
