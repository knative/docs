#!/bin/bash
echo "Start APL run-script.sh"

export CodeLocation=$APP_HOME/aplcode
echo "Start APL interpreter"

echo "Print ev. variables:"
echo "APP_HOME: ${APP_HOME}"

echo "What is at $APP_HOME folder"
ls -la $APP_HOME

echo "What is at $APP_HOME/aplcode folder"
ls -la $APP_HOME/aplcode

echo "Ready to go at $APP_HOME/init/init.apl"

$APP_HOME/run-script.sh $APP_HOME/init/init.apl

exit 0