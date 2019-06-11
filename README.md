## rclone bash wrapper ##

This started as a simple bash script to make defining various sources/destinations and running with the various arguments I wanted quicker and easier across multiple machines, especially laptops.

It's quite opinionated, but could give someone a structure to (mis)use for their own rclone wrapper or whatever.

### requirements ###
- rclone v1.42+ [here](https://rclone.org/downloads/)
    + install from there, your package manager probably doesn't have the newer version (ubuntu 18 doesn't) and some of the arguments use require this.

#### optional ####
`curl` (you probably already have it) and a [MailGun](https://www.mailgun.com/) account to send failure notifications. 

### features ###
- easy and separated src/dest configuration files. You could easily just make one(s) to suit your needs and be done.
- built-in semi-validation of the config files (not for filters)
- laptop frienldy
    + network connectivity check so it won't try to run when it can't reach the outide world
    + configurable "only run once per X hours" - let's you schedule the script to run often (cron) without it constantly trying to run backups
- logging
    + logs the full script and rclone output to both stdout and a file per run
    + configurable number of log files to keep around (eg, defaults to last 20)
- can mail the run's complete log file if errors occur
- pretty decent code separation so it's easier to naviagate/modify

### limitations ###
- again, opinionated.
- currently only uses rclone's `sync`
- loads of other rclone arguments are not used, may require a bunch of changes if you have crazy requirements
    + then again, with the code separated as it is, wouldn't be too hard to pop new function/vars
- if anyone ever creates a pull request, it will probably be to add to this list

### installation ###
- download the zip file from above and extract it to its own directory. The scripts are competely self-contained there with regards to writing any files
- configure it (as below)

### running ###
0. do the configuration stuff below
1. exec the rclone_backup.sh - `./rclone_backup.sh` or `sh rclone_backup.sh`
2. set it up as a cron job if you'd like (it will figure out its own root path)

### configuring ###

1. [Configure](https://rclone.org/docs/) at least 1 storage system using `rclone config`
2. Edit your "bucket" (source/destination) **config** and **filter** files in the `config/` directory. See below for an example.
3. Peruse the `inc/defaults.sh` file and make any changes you feel necessary.
    -   hopefully the MAILGUN_* params are self-explanatory

#### config files ####
Each "set" or "bucket" (my terms) consists of a **config** and a **filter**. Again, both of these must live in the `config/` directory. When the backup script runs, it will process **all** `.sh` files there.

A **config** file will look like this and contain _all_ of the vars you see here:
```sh
FILTER_FILE="home_dirs.txt"
SOURCE_PATH=/home/$USER_NAME
DESTINATION_PATH="s3:mydomain.com/backups/${COMPUTER_NAME}/${USER_NAME}"
ARCHIVE_DESTINATION_PATH="s3:mydomain.com/backups/${COMPUTER_NAME}/${USER_NAME}_archive"
```
- **FILTER_FILE** - the file containing rules rclone will use via its _--filter-from_ arg. See below.
- **SOURCE_PATH** - the root path rules will be applied to (no trailing /)
- **DESTINATION_PATH** and **ARCHIVE_DESTINATION_PATH** - these will vary based on the [storage system(s) configured](https://rclone.org/docs/) and used. Note that they must be in the same storage bucket
    - **ARCHIVE_DESTINATION_PATH** is currently not used, but needs to be set

A **filter** file
```
# get the excludes out in front to prevent rclone from finding things we really don't want (like Trash in .local)
- backup/*.log
- .local/*
- .local/**

# normal folders
+ backup/*
+ Documents/*
+ Photos/*
+ Pictures/*

# dot dirs
+ .config/*
+ .gnupg/**
+ .ssh/*
+ .vim/*

# dot files
+ .bashrc
+ .gitconfig
+ .profile
+ .vimrc

# individual home files
+ setup_notes.txt
+ gpg.pubkey_armor

# and nothing else
- *
- **
```

Nothing specific to this script setup, just built based on:
- [generic filter details](https://rclone.org/filtering/)
- [specific to filter-file](https://rclone.org/filtering/#how-the-rules-are-used)
- pay particular attention to the leading **+ / -** for each line
