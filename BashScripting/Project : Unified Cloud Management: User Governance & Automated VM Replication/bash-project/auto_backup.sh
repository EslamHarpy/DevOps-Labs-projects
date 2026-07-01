#!/bin/bash

# ==============================================================================
# Description: This script automates local directory backups into a compressed 
#              tar.gz archive and securely uploads them to an Amazon S3 bucket. 
#              It includes verification checks for AWS CLI availability and logs 
#              the entire workflow sequence.
# ==============================================================================

# 1. Define and initialize variables
time=$(date +%m-%d-%y_%H_%M_%S)
Backup_file="/home/ubuntu/bash-project/menu_miniproject"
Dest="/home/ubuntu/bash-project/backup"
filename="file-backup-$time.tar.gz"
LOG_FILE="/home/ubuntu/bash-project/backup/logfile.log"

S3_BUCKET="s3-new-bash-course-harpy"  # Confirmed S3 Bucket name
FILE_TO_UPLOAD="$Dest/$filename"

# 2. Check if AWS CLI is installed on the system
if ! command -v aws &> /dev/null; then
    echo "[$(date)] ERROR: AWS CLI is not installed. Please install it first." | tee -a "$LOG_FILE"
    exit 2
fi

# 3. Ensure the local destination backup directory exists
mkdir -p "$Dest"

echo "[$(date)] START: Creating local tar.gz backup..." | tee -a "$LOG_FILE"

# 4. Execute local compression and archiving
tar -czf "$FILE_TO_UPLOAD" -C "$(dirname "$Backup_file")" "$(basename "$Backup_file")" 2>> "$LOG_FILE"

# Verify local backup success before initiating cloud upload
if [ $? -eq 0 ]; then
    echo "[$(date)] SUCCESS: Local backup created at $FILE_TO_UPLOAD" | tee -a "$LOG_FILE"
    echo "--------------------------------------------------------" | tee -a "$LOG_FILE"
    echo "[$(date)] START: Uploading backup to AWS S3 ($S3_BUCKET)..." | tee -a "$LOG_FILE"
    
    # 5. Upload the compressed archive to the Amazon S3 Bucket
    aws s3 cp "$FILE_TO_UPLOAD" "s3://$S3_BUCKET/" >> "$LOG_FILE" 2>&1
    
    # Verify cloud upload success
    if [ $? -eq 0 ]; then
        echo "[$(date)] SUCCESS: File uploaded successfully to S3 bucket: $S3_BUCKET" | tee -a "$LOG_FILE"
        echo "Process completed successfully!"
    else
        echo "[$(date)] ERROR: File upload to S3 failed. Check logfile.log" | tee -a "$LOG_FILE"
        echo "Upload failed!"
    fi
else
    echo "[$(date)] ERROR: Local backup creation failed. Check logfile.log" | tee -a "$LOG_FILE"
    echo "Backup failed!"
fi
