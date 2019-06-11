# Default vars for setting up destination paths... DEST_BUCKET/computer_name/user_name
COMPUTER_NAME=$(hostname -s)
USER_NAME=$(whoami)

# Script will exit if a non-failed backup has been run less than this many hours ago.
# Convenient to scheduling frequently (like hourly) on laptops, but not actually runninng
# a backup everytime
# Default = 12
MIN_HOURS=12

# Maximum number of log files to leave around
# Default = 20
LOGS_TO_KEEP=20

# Use sudo if we can? Used to "nice" the rclone command and run it in case you're 
# trying to backup stuff you can't access w/o it.
# 1 == Yes
# 0 == No (0 or anything else)
USE_SUDO=1


#############################################
# MailGun Setup
# If an API Key is entered, the script automatically tries to send an email on failure.
#############################################
MAILGUN_DOMAIN="example.net"
MAILGUN_APIKEY="key-MYKEY"
MAILGUN_FROM="support@example.org"
MAILGUN_TO="me@example.com"
MAILGUN_SUBJECT="$COMPUTER_NAME / $USER_NAME backup problem!"


####### These probably don't need to be changed #######
# The file we drop after backups
# Default = "$SCRIPT_HOME/.lastrun"
LASTFILE="$SCRIPT_HOME/.lastrun"

# Leave this alone - used to track failures during a single backup run
# Default = 0
FAILURE=0

#############################################

# If we can sudo (or are root), "nice" rclone to prevent it from slowing other stuff down.
# Default = -5
NICE=-5

IS_ROOT=0
if [ "$EUID" -eq "0" ]; then
    IS_ROOT=1
fi