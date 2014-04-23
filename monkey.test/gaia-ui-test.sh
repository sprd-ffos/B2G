B2G_DIR=$(cd "$(dirname "$0")"; pwd)/..
MARIONETTE_DIR="$B2G_DIR/gecko/testing/marionette/client/marionette"
GAIA_TEST_DIR="$B2G_DIR/gaia/tests/python/gaia-ui-tests"

echo $MARONEETTE_DIR
cd $MARIONETTE_DIR
bash venv_test.sh ~/bin/Python2.7.2/
cd ../marionette_venv
. bin/activate
cd ..
python setup.py develop

cd $GAIA_TEST_DIR
adb forward tcp:2828 tcp:2828
gaiatest --address=localhost:2828 --testvars=gaiatest/testvars_template.json ./gaiatest/tests/
