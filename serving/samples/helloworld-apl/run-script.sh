#!/bin/bash
echo "Start APL run-script.sh"

export Port=8080
export CodeLocation=/aplcode
export Threaded=0
export AllowHttpGet=1
export Logging=1
echo "Start APL interpreter"

echo "Print ev. variables:"
echo "APP_HOME: ${$APP_HOME}"

echo "What is at /aplcode folder"
ls -la /aplcode

echo "Ready to go:"

/run </init/init.apl

exit 0