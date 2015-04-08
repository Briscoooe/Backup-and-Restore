# Brian Briscoe
# C12468098
# Sat 4 April 2015
# Software Installation and Maintenance
# Assignment 1
# Backup and Restore script

#!/bin/bash

clear

# This function adds the cron job to the cron table
add_cron()
{
	crontab -l | { cat; echo "$1 rsync -avbzhe ssh --delete --progress --max-size='10000k' --exclude-from 'exclude_list.txt' / user@83.212.127.62:$location;"; } | crontab -;
}

choices="Full_Backup Incremental_Backup Schedule_Backup View_Scheduled_Backups Restore_Most_Recent_Backup Quit"

select options in $choices; do
if [ "$options" = "Full_Backup" ]; then
	read -p "Enter the ABSOLUTE path for the backup to be stored " location;

	# Adding the path to the exclude list to avoid an infinite loop
	echo $location >> exclude_list.txt;

	# Making the backup directory in case it doesn't exist already
	mkdir -p $location;

	echo "Starting intial backup";
	rsync -avzhe ssh --progress --delete --max-size='10000k' --exclude-from 'exclude_list.txt' / user@83.212.127.62:$location;
	echo -e "\nInitial backup complete!";

elif [ "$options" = "Incremental_Backup" ]; then
	read -p "Enter the ABSOLUTE path for the backup to be stored " location;

	# Adding the path to the exclude list to avoid an infinite loop
        echo $location >> exclude_list.txt;

        # Making the backup directory in case it doesn't exist already
        mkdir -p $location;

        echo "Starting incremental backup";
        rsync -abvzhe ssh --progress --delete --max-size='10000k' --exclude-from 'exclude_list.txt' / user@83.212.127.62:$location;
        echo -e "\nIncremental backup complete!";

elif [ "$options" = "Schedule_Backup" ]; then
	read -p "Enter the ABSOLUTE path for the backup to be stored " location;
	echo $location >> exclude_list.txt;

	# Making the backup directory in case it doesn't exist already
	mkdir -p $location;

	echo "How frequently would you like the backup to be done?"

	cron_choices="Annually Monthly Weekly Daily"
	select cron_options in $cron_choices; do
	if [ "$cron_options" = "Annually" ]; then
		add_cron @annually ;
		echo "Annual crontab added. Backing up folder / to location $location";
		break;
	elif [ "$cron_options" = "Monthly" ]; then
		add_cron @monthly ;
		echo "Monthly crontab added. Backing up folder / to location $location";
		break;
	elif [ "$cron_options" = "Weekly" ]; then
		add_cron @weekly ;
		echo "Weekly crontab added. Backing up folder / to location $location";
		break;
	elif [ "$cron_options" = "Daily" ]; then
		add_cron @daily ;
		echo "Daily crontab added. Backing up folder / to location $location";
		break;
	fi
	done
elif [ "$options" = "View_Scheduled_Backups" ]; then
	crontab -l;
elif [ "$options" = "Restore_Most_Recent_Backup" ]; then
	rsync -avr ssh --progress --delete * user@83.212.127.62:/;
	echo "Most recent backup restored"
elif [ "$options" = "Quit" ]; then
	exit;
else
	echo "Please select a valid option";
fi
done
