echo -n "Enter your password:"
read passwd
./env_pre.sh --dev sp8810eabase_512x256_hvga --passwd $passwd
./run_test.sh --config tara.config
