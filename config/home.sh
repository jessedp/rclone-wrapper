FILTER_FILE="home_dirs.txt"
SOURCE_PATH=/home/$USER_NAME
DESTINATION_PATH="s3:mydomain.com/backups/${COMPUTER_NAME}/${USER_NAME}"
ARCHIVE_DESTINATION_PATH="s3:mydomain.com/backups/${COMPUTER_NAME}/${USER_NAME}_archive"