#!/bin/bash

## This file replaces the Dyalog mapl script
echo " _______     __      _      ____   _____ "
echo "|  __ \ \   / //\   | |    / __ \ / ____|"
echo "|_|  | \ \_/ //  \  | |   | |  | | |     "
echo "     | |\   // /\ \ | |   | |  | | |   _ "
echo " ____| | | |/ /  \ \| |___| |__| | |__| |"
echo "|_____/  |_/_/    \_\______\____/ \_____|"
echo ""
echo "https://www.dyalog.com"
echo ""
echo "*************************************************************************************"
echo "*               This software is for non-commercial evaluation ONLY                 *"
echo "* https://www.dyalog.com/uploads/documents/Private_Personal_Educational_Licence.pdf *"
echo "*************************************************************************************"
echo ""

export MAXWS=${MAXWS-256M}

export DYALOG=/opt/mdyalog/17.1/64/unicode/
export WSPATH=/opt/mdyalog/17.1/64/unicode/ws
export TERM=xterm
export APL_TEXTINAPLCORE=${APL_TEXTINAPLCORE-1}
export TRACE_ON_ERROR=0
export SESSION_FILE="${SESSION_FILE-$DYALOG/default.dse}"

echo "Start up script at $@"
# Used +s as SALT is needed in JSON server to load files.
$DYALOG/dyalog +s <$@  # Add "<" to start APL script.
