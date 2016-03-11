# Backup-and-Restore
A user-friendly shell script to allow for simple configurations of rsync backups via a command line menu.

## Description
The home menu of the script gives users the options or performing a full backup, incremental backup, scheduled backup, view a list of active scheduled backup operations or to restore from the most recent backup. The full and incremental backups allow the users to select folders to be backed up, a storage location for backups. The schedule backup option allows the user to set a frequency for the backup operation which is then added to the crontab. 
