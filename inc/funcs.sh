# See if it's time to do a full run or bail
shouldRun() {
    if [ -e "$LASTFILE" ]; then

        NOW=$(date +%s)
        local LAST

        # Determine OS for stat command
        if [[ "$(uname -s)" == "Darwin" ]]; then
            # macOS (BSD stat)
            LAST=$(stat -f %m "$LASTFILE")
        else
            # Linux and others (GNU stat)
            LAST=$(stat -c %Y "$LASTFILE")
        fi

        DIFF=$(expr "$NOW" - "$LAST")
        HR_DIFF=$(expr "$DIFF" / 60 / 60)
        if [ "$HR_DIFF" -lt "$MIN_HOURS" ]; then
            echo "Only $HR_DIFF hours have elapsed since the last backup. Waiting for at least $(expr "$MIN_HOURS" - "$HR_DIFF") hours before running again."
            rm "$LOGFILE"
            exit
        fi
    fi
}

# make sure we have a network connection, otherwise our purpose for this is futile
checkNetwork() {
    log "Checking network connectivity..."
    if ping -q -c 4 -W 5 google.com >/dev/null 2>&1; then
        NET_UP=true
        log "Network up."
    else
      log "The network is down, not running backup"
      exit -1
    fi  
}

# used by validateConfig - wipes out the bucket vars to make sure we're validating each one on its own
resetConfig() {
    FILTER_FILE=""
    SOURCE_PATH=""
    DESTINATION_PATH=""
    ARCHIVE_DESTINATION_PATH=""
}

# validate - as in make sure they are filled in - the bucket vars we're going to use.
validateConfig() {
    BADCFG=0
    for CFGFILE in "$SCRIPT_HOME"/config/*.sh;
    do 
        resetConfig
        source "$CFGFILE"

        echo "Validating required fields in: $CFGFILE"
        
        declare -a fields=("FILTER_FILE" "SOURCE_PATH" "DESTINATION_PATH" "ARCHIVE_DESTINATION_PATH")
        
        for field in "${fields[@]}"
        do
           TEST="$(echo -e "${!field}" | tr -d '[:space:]')"
           if [ -z "$TEST" ]; then
                echo -e "\tBAD: $field can not be empty!"
                BADCFG=1
           else
                echo -e "\tGood: $field (${!field})"
           fi
        done
    done

    if [ $BADCFG != 0 ]; then
        echo -e "\nThere are errors in you config files. Please correct them.\n"
        exit
    fi

}

# run the indiivual backup for each bucket config
runBackups() {
    for CFGFILE in "$SCRIPT_HOME"/config/*.sh; 
    do 
        source "$CFGFILE"
        backup
    done
    finish
}

# This wraps up the rclone command and params to run each for each bucket config
backup() {
    log "Starting backup of $SOURCE_PATH dirs"
    NICE_CMD=""
    if [ $IS_ROOT == 1 ]; then
        NICE_CMD="nice -n $NICE"
    elif [ $USE_SUDO == 1 ]; then
        NICE_CMD="sudo nice -n $NICE"
    fi

    (set -x; \
    /usr/bin/time -v -o $LOGFILE -a \
        $NICE_CMD -n "$NICE" rclone sync "$SOURCE_PATH" "$DESTINATION_PATH" \
        --delete-excluded \
        --filter-from "$SCRIPT_HOME/config/$FILTER_FILE" \
        --log-file="$LOGFILE" \
        --log-level INFO \
        --track-renames \
        --skip-links \
        --stats-log-level DEBUG \
        --update >> $LOGFILE;
    )

    #  --backup-dir=$ARCHIVE_DESTINATION_PATH \
    #  -vvv
    #  --dry-run  -vvv

    if [ $? != 0 ]; then
        FAILURE=1
        log "BACKUP FAILED - ${SOURCE_PATH} dirs  - ${?}"
    else
        log "FINISHED BACKUP - ${SOURCE_PATH} dirs"
    fi
}

# if configured, try to email you/someone if there's a problem with the backups
notifyFailure() {
    if [ -z "$(which curl)" ]; then
        log "curl not found, can't send notifications!"
    elif [ -n "$MAILGUN_APIKEY" ]; then
        log "Attempting to notify about backup problem..."
        RESULT=`curl -o /dev/null -s -w "%{http_code}\n" --user "api:$MAILGUN_APIKEY" \
            https://api.mailgun.net/v3/"$MAILGUN_DOMAIN"/messages \
            -F from=$MAILGUN_FROM \
            -F to=$MAILGUN_TO \
            -F subject="$MAILGUN_SUBJECT" \
            -F text="$(cat "$LOGFILE")" `

        if [[ $RESULT == 2* ]]; then
            log "Error email sent"
        else
            log "UNABLE to send error email! HTTP RESP: $RESULT"
        fi
    else
        log "Problem with backup, but no notification option configured..."
    fi
}


finish() {
    touch "$LASTFILE"
    if [ $FAILURE == 1 ]; then
        notifyFailure
    fi
}
