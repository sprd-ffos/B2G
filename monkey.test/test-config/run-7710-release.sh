cd $(cd "$(dirname "$0")"; pwd)/..
./update_script.sh
TEST_CONFIG=test-config/7710.release.config ./test_main.sh
