#!/bin/bash

# ==============================================================================
# Description: This is the main dashboard script that provides a TUI (Text User 
#              Interface) using 'whiptail'. It orchestrates various system 
#              administration tasks including user/group management, account 
#              locking/unlocking, password changes, and automated S3 backup integrations.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/home/ubuntu/bash-project/backup/logfile.log"

while true; do
    # Added new layout options for Backups and Logs in the menu (interface size adjusted to 24 75 14)
    CHOICE=$(whiptail --title "Main Menu" --menu "Choose an operation:" 24 75 14 \
        "Add User" "Add a user to the system." \
        "Modify User" "Modify an existing user." \
        "Delete User" "Delete an existing user." \
        "List Users" "List all users on the system." \
        "Add Group" "Add a user group to the system." \
        "Modify Group" "Modify a group and its list of members." \
        "Delete Group" "Delete an existing group." \
        "List Groups" "List all groups on the system." \
        "Disable User" "Lock the user account." \
        "Enable User" "Unlock the user account." \
        "Change Password" "Change Password of a user." \
        "System Backup" "Create instant backup & replicate to Amazon S3." \
        "View Backup Logs" "Display the automated backup log file history." \
        "About" "Information about this program." \
        3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        clear
        echo "Exiting program..."
        break
    fi

    case "$CHOICE" in
        "Add User") "$SCRIPT_DIR/add_user.sh" ;;
        "Modify User") "$SCRIPT_DIR/modify_user.sh" ;;
        "Delete User") "$SCRIPT_DIR/delete_user.sh" ;;
        "List Users") "$SCRIPT_DIR/list_users.sh" ;;
        "Add Group") "$SCRIPT_DIR/add_group.sh" ;;
        "Modify Group") "$SCRIPT_DIR/modify_group.sh" ;;
        "Delete Group") "$SCRIPT_DIR/delete_group.sh" ;;
        "List Groups") "$SCRIPT_DIR/list_groups.sh" ;;
        "Disable User") "$SCRIPT_DIR/disable_user.sh" ;;
        "Enable User") "$SCRIPT_DIR/enable_user.sh" ;;
        "Change Password")
            clear
            "$SCRIPT_DIR/change_password.sh"
            echo "Press Enter to return to main menu..."
            read
            ;;
        "System Backup")
            # Invoke the newly implemented backup script
            "$SCRIPT_DIR/system_backup.sh"
            ;;
        "View Backup Logs")
            # Smart feature to display the last 20 lines of the log file inside a Whiptail message box
            if [ -f "$LOG_FILE" ]; then
                LATEST_LOGS=$(tail -n 20 "$LOG_FILE")
                whiptail --title "Latest Backup Logs" --msgbox "$LATEST_LOGS" 22 70
            else
                whiptail --title "Error" --msgbox "Log file not found yet!" 10 45
            fi
            ;;
        "About")
            whiptail --title "About" --msgbox "Advanced User Management & Cloud Automation System v2.0\n\nAutomated Backups are currently active via Crontab." 12 60 ;;
    esac
done
