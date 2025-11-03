BASH-SCRIPTING

This repository contains a simple bash scripting project that helps automate backups for your files and folders.
Below is a summary explaining each part of the project.

Folder Structure
text
bashscripting_test/
  backups/
    backup.log
  data_folder/
  backup.config
  backup.log
  backup.sh
README.md

Explanation of Files and Folders
backups/
Stores backup logs. The backup.log here saves records of backup operations performed by the script.

data_folder/
Contains the data/files that need to be backed up. Place any files or subfolders here that you want the backup script to process.


backup.config
A configuration file that holds settings for the backup script, such as source and destination paths, exclusions, or log locations.

backup.log
A log file at the root level that records a summary of backup operations, errors, and details for easy troubleshooting.

backup.sh
The main bash script that performs the backup operations. It reads configuration from backup.config, scans files in data_folder
copies them to the backup destination, and updates the logs.


How to Use
Edit backup.config:
Set your backup preferences such as which folders to back up, where to save backups, and log file locations.

Put Files in data_folder/:
Add any content you want to include in the backup.

Run the Script:
Use the terminal.

text
bash backup.sh
This will automatically copy files and generate/update log entries of everything done.

Check Logs:
Review backups/backup.log or the root level backup.log to monitor backup status or debug issues.

Run the command:
bash
./backup.sh data_folder

![WhatsApp Image 2025-11-03 at 16 28 30_b4e40b18](https://github.com/user-attachments/assets/a92c3b93-970f-4e24-bfbf-0d469527945a)

Purose of bashscripting
This project demonstrates a simple way to automate file backups and logging using bash scripts.
It can be extended for more complex backup needs, scheduled jobs, or custom rules.
