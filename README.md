Bash Scripting – Automated Backup System

This repository contains a **simple yet powerful Bash scripting project** that automates backups for your files and folders.  
It’s designed to help you practice real-world shell scripting concepts like file management, logging, configuration handling, and automation.

Folder Structure
bashscripting_test/
│
├── backups/ # Stores generated backup files (.tar.gz)
│ └── backup.log # Log file recording all backup activities
│
├── data_folder/ # Folder containing the files/folders to back up
│
├── backup.config # Configuration file for the backup script
├── backup.log # Root-level log for summary and errors
├── backup.sh # Main Bash script that handles backup & restore
└── README.md # Project documentation

## 'backups/'
This directory stores all the backup archives (e.g., `backup-2025-11-03-1612.tar.gz`) and the backup logs.  
It’s automatically created if it doesn’t exist.


## 'data_folder/'
Contains the data/files you want to back up.  
You can place any files or folders here — the script will automatically include them in the backup process.


## 'Contains the data/files you want to back up.  
Holds the configuration details for your script, such as:
- Source and destination paths  
- Log file location  
- Backup naming format  


## 'backup.log'
Records a summary of all backup and restore operations, including:
- Timestamp  
- Action performed (backup/restore)  
- File names  
- Success or failure messages  

##  'backup.sh'
The main executable Bash script that performs:
- Backup creation (compresses source data into `.tar.gz`)  
- Restore operations from an existing backup file  
- Log management and error handling  


How to use

Open the `backup.config` file and update your preferences:
```bash
SOURCE="./data_folder"
DESTINATION="./backups"
LOG_FILE="./backup.log"

1.Add Files for Backup

Place any files or folders you want to back up inside the data_folder/ directory.

2.Run the Script
Use your terminal to execute the script:

bash backup.sh

3.Restore a Backup

To restore a specific backup archive:

./backup.sh --restore backups/backup-YYYY-MM-DD-HHMM.tar.gz --to ./restored_data

This will extract the selected backup into the specified folder.

4.Check Logs

You can review the logs at:

backups/backup.log – detailed log

backup.log – summary log in the main directory

5.Here’s how you might run a typical backup:

./backup.sh ./data_folder

<img width="1674" height="387" alt="image" src="https://github.com/user-attachments/assets/7b4fa848-633a-4c2a-b84c-1548fb6c87a1" />









