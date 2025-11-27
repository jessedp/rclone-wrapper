#!/bin/bash
set -euo pipefail

# Don't change this! It allows all our scripts to base include, log, etc. paths off the
# directory the backup script lives in to keep everything contained.
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#######

# Include everything we need to run... change the order at your own risk (don't do it)
source "$SCRIPT_HOME/inc/logging.sh" || exit 1
rm "$LOGFILE"

LATEST_LOG=$(ls -1rt "$LOGDIR" | tail -n 1)

if [ -z "$LATEST_LOG" ]; then
    echo "No log files found in $LOGDIR"
    exit 1
fi

tail -f "$LOGDIR/$LATEST_LOG"
