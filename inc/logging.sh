# Setup logging
LOGDIR="$SCRIPT_HOME/logs"
LOGFILE="$LOGDIR/backup_$(date +'%Y%m%d_%H%M%S').log"
mkdir -p $LOGDIR
touch $LOGFILE



# Logs to both the screen and to rclone's log file (in the same format as rclone)
log() {
    date=$(date +'%Y/%m/%d %H:%M:%S')
    echo -e "$date $1"
    echo -e "$date **SH**: $1" >> $LOGFILE
}

cleanupLogs() {
    REMOVE=$(expr $(ls $LOGDIR/ -1rt | wc -l) - $LOGS_TO_KEEP)
    for i in $(ls $LOGDIR/ -1rt | head -n $REMOVE);
    do
        rm "$LOGDIR/$i";
    done
    log "Cleaned up $REMOVE old log files, $LOGS_TO_KEEP remain"
}