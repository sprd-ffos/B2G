#!/bin/bash
./system.config

log_file "Update test script"

echo "Update script from service now. It is about 15-30s, Please wait..."
cd ..
git fetch origin
git checkout origin/sprdroid4.0.3_vlx_3.0_b2g
