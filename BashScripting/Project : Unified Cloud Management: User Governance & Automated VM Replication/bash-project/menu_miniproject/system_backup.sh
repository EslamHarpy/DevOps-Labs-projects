#!/bin/bash

# ==============================================================================
# Description: This script performs an on-demand system backup initiated from 
#              the main menu. It ensures destination directory permissions, 
#              creates a local compressed tar.gz archive while displaying a 
#              whiptail infobox, replicates the backup to an Amazon S3 bucket 
#              using an absolute AWS CLI path, and logs all execution details.
# ==============================================================================

# 1. Initialize core variables
time=$(date +%m-%d-%y_%H_%M_%S)
Backup_file="/home/ubuntu/bash-project/menu_miniproject"
Dest="/home/ubuntu/bash-project/backup"
filename="file-backup-$time.tar.gz"
LOG_FILE="/home/ubuntu/bash-project/backup/logfile.log"

S3_BUCKET="s3-new-bash-course-harpy"
FILE_TO_UPLOAD="$Dest/$filename"

# Ensure the local destination directory exists and grant full permissions
mkdir -p "$Dest"
chmod 777 "$Dest"

echo "[$(date)] INFO: Manual backup requested via Main Menu" >> "$LOG_FILE"

# 2. Display a temporary flash message on the screen using Whiptail
whiptail --title "Backup & Cloud Synchronization" --infobox "Processing backup and replicating to Amazon S3...\nPlease wait..." 8 60

# 3. Execute local compression and archiving
tar -czf "$FILE_TO_UPLOAD" -C "$(dirname "$Backup_file")" "$(basename "$Backup_file")" 2>> "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date)] SUCCESS: Local backup created at $FILE_TO_UPLOAD" >> "$LOG_FILE"
    
    # 4. Immediate cloud replication to Amazon S3 using absolute path
    /usr/local/bin/aws s3 cp "$FILE_TO_UPLOAD" "s3://$S3_BUCKET/" >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "[$(date)] SUCCESS: Replicated to S3 Bucket ($S3_BUCKET) successfully" >> "$LOG_FILE"
        UPLOAD_STATUS="SUCCESS"
    else
        echo "[$(date)] ERROR: S3 Replication failed" >> "$LOG_FILE"
        UPLOAD_STATUS="S3_FAILED"
    fi
else
    echo "[$(date)] ERROR: Local backup creation failed" >> "$LOG_FILE"
    UPLOAD_STATUS="LOCAL_FAILED"
fi

# 5. Clear terminal screen layout and present the final interactive dialog box
clear

if [ "$UPLOAD_STATUS" == "SUCCESS" ]; then
    whiptail --title "🎉 Backup & Replication Successful" --msgbox \
"The manual backup process completed successfully!

📁 File Name:
$filename

📍 Local Destination:
$Dest/

☁️ Cloud Storage:
Successfully uploaded to S3 Bucket ($S3_BUCKET)" 16 65

elif [ "$UPLOAD_STATUS" == "S3_FAILED" ]; then
    whiptail --title "⚠️ S3 Replication Warning" --msgbox \
"Local backup was created successfully inside:
$Dest/$filename

However, the replication to Amazon S3 FAILED!
Please inspect the log history for details." 14 65
else
    whiptail --title "❌ Critical Backup Error" --msgbox \
"Failed to create the local compressed archive backup.
The entire process has been aborted. Check logfile.log immediately." 12 65
fi
