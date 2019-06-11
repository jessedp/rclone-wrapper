# Setup logging
LOGDIR="$SCRIPT_HOME/logs"
LOGFILE="$LOGDIR/backup_$(date +'%Y%m%d_%H%M%S').log"
mkdir -p $LOGDIR
touch $LOGFILE



# Logs to both the screen and to rclone's log file (in the same format as rclone)
log() {
    date=$(date +'%Y/%m/%d %H:%M:%S')
    if [ "$CRON" != "1" ]; then
        echo -e "$date $1"
    fi
    echo -e "$date **SH**: $1" >> $LOGFILE
}

cleanupLogs() {
    REMOVE=$(expr $(ls $LOGDIR/ -1rt | wc -l) - $LOGS_TO_KEEP)
    if [ "$REMOVE" > 1 ]; then
        for i in $(ls $LOGDIR/ -1rt | head -n $REMOVE);
        do
            rm "$LOGDIR/$i";
        done
        log "Cleaned up $REMOVE old log files, $LOGS_TO_KEEP remain."
    else
        log "Fewer then $LOGS_TO_KEEP log fils remain, all retained."
    fi
}
