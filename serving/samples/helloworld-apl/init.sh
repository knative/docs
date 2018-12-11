#!/bin/bash
echo "Starts Dyalog APL image run(-script).sh"

export CodeLocation=$APP_HOME/aplcode

# Start updated Dyalog (with APL script support) image startup shell script:
$APP_HOME/run-script.sh $APP_HOME/init/init.apl