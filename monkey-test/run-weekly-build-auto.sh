echo -n "Enter your password:"
read passwd
./env_pre.sh --dev sp8810eabase_weekly_build --passwd $passwd
./run_test.sh --config tara.config
