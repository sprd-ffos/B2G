#!/bin/bash
#change dir to test script
cd ..
#update the test script to keep the script always newest
./update_script.sh
#set config file to env VARIABLR, then run test script
TEST_CONFIG=7710.hudson.config ./test_main.sh
