# Rclone Bash Wrapper

## Project Overview
This project is a Bash-based wrapper for **rclone**, designed to simplify and automate the process of defining and running backup jobs across multiple machines. It provides a structured way to manage backup sources, destinations, and filters, along with built-in features like logging, network checks, and failure notifications.

## Key Features
*   **Configuration Separation:** distinct source/destination configuration files and filter lists.
*   **Automated Checks:**
    *   **Network Connectivity:** Verifies internet access (via Google ping) before attempting backups.
    *   **Frequency Control:** `MIN_HOURS` setting prevents the script from running too frequently (e.g., when scheduled via cron).
*   **Logging:** Detailed logs for both the script and `rclone` output, with automatic rotation (`LOGS_TO_KEEP`).
*   **Notifications:** Optional MailGun integration to send email alerts on backup failures.
*   **Cross-Platform:** Tested and hardened for both Linux and macOS environments.

## Directory Structure

*   **`rclone_backup.sh`**: The main entry point script.
*   **`tail_log.sh`**: Utility to tail the latest log file.
*   **`view_log.sh`**: Utility to view the latest log file with `less`.
*   **`config/`**: Contains configuration files for backup jobs.
    *   `*.sh`: "Bucket" config files defining `SOURCE_PATH`, `DESTINATION_PATH`, and the `FILTER_FILE` to use.
    *   `*.txt` (or others): Filter files containing `rclone` include/exclude rules.
*   **`inc/`**: Helper scripts sourced by the main script.
    *   `defaults.sh`: Global variables (user, computer name, API keys, etc.).
    *   `funcs.sh`: Core logic functions (backup execution, validation, network check, cross-platform stat/date handling).
    *   `logging.sh`: Logging setup and rotation logic.
*   **`logs/`**: Directory where run logs are stored.

## Setup & Configuration

### 1. Prerequisites
*   **rclone v1.42+**: Must be installed and in the system PATH.
*   **Storage Config**: Run `rclone config` manually to set up your remote storage remotes (e.g., S3, Google Drive).
*   **(Optional) curl**: Required for MailGun notifications.

### 2. Global Settings (`inc/defaults.sh`)
Edit `inc/defaults.sh` to configure:
*   **`MIN_HOURS`**: Minimum time (hours) between successful runs.
*   **`LOGS_TO_KEEP`**: Number of old log files to retain.
*   **`MAILGUN_*`**: API credentials for failure notifications (leave blank if unused).

### 3. Job Configuration (`config/`)
The script iterates through **all** `.sh` files in the `config/` directory. To add a backup job, create a new `.sh` file in `config/` with the following variables:

```bash
FILTER_FILE="my_filter.txt" # Must exist in config/
SOURCE_PATH=/path/to/source
DESTINATION_PATH="remote:bucket/path"
ARCHIVE_DESTINATION_PATH="remote:bucket/archive_path" # Currently unused but required
```

Create the corresponding filter file (e.g., `config/my_filter.txt`) using standard [rclone filtering rules](https://rclone.org/filtering/).

## Usage

### Manual Run
```bash
./rclone_backup.sh
```

### View Logs
```bash
./tail_log.sh  # Follow the latest log file
./view_log.sh  # Open the latest log file in less
```

### Cron Job
The script detects its own location, so it is safe to run via cron. Example (run every hour):
```cron
0 * * * * /path/to/rclone-wrapper/rclone_backup.sh
```

## Development Practices

This project adheres to strict bash scripting standards to ensure reliability and safety.

*   **Strict Mode:** All scripts must begin with `set -euo pipefail` to fail fast on errors, unset variables, or pipeline failures.
*   **Variable Quoting:** All variables, especially those representing file paths (e.g., `"$SOURCE_PATH"`, `"$LOGFILE"`), must be double-quoted to correctly handle spaces.
*   **Cross-Platform Compatibility:**
    *   Scripts must work on both Linux (GNU tools) and macOS (BSD tools).
    *   Use logic (e.g., `uname -s`) to handle differences in commands like `stat` and `ls`.
*   **Git & GitHub:**
    *   We use **git** for version control.
    *   We use the **GitHub CLI (`gh`)** for managing issues and interactions with the remote repository.
    *   Commit messages should be descriptive and follow conventional commit patterns where possible.
*   **Validation:** The script runs `validateConfig` before backups to ensure all required variables are present in the config files.
