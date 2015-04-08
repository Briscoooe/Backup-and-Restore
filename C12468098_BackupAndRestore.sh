# Brian Briscoe
# C12468098
# Sat 4 April 2015
# Software Installation and Maintenance
# Assignment 1
# Backup and Restore script

#!/bin/bash

clear

# This function is used to validate yes or no answers inputted by the user
# It was taken from this public GitHub repository https://gist.github.com/davejamesmiller/1965569

ask()
{
	while true; do

		if [ "${2:-}" = "Y" ]; then
			prompt="Y/n"
			default=Y
		elif [ "${2:-}" = "N" ]; then
			prompt="y/N"
			default=N
		else
			prompt="y/n"
			default=
		fi

		# Ask the question - use /dev/tty in case stdin is redirected from somewhere else
		read -p "$1 [$prompt] " REPLY </dev/tty

		# Default?
		if [ -z "$REPLY" ]; then
			REPLY=$default
		fi

		# Check if the reply is valid
		case "$REPLY" in
			Y*|y*) return 0 ;;
			N*|n*) return 1 ;;
		esac

	done
}

# This function adds the cron job to the cron table
add_cron()
{
	crontab -l | { cat; echo "$1 rsync -avbzhe ssh --delete --progress --max-size='10000k' --exclude-from 'exclude_list.txt' / $location;"; } | crontab -;
}

choices="Full_Backup Schedule_Backup View_Scheduled_Backups Restore Quit"

select options in $choices; do
if [ "$options" = "Full_Backup" ]; then
	read -p "Enter the ABSOLUTE path for the backup to be stored " location;

	# Adding the path to the exclude list to avoid an infinite loop
	echo $location >> exclude_list.txt;

	# Making the backup directory in case it doesn't exist already
	mkdir -p $location;

	echo "Starting intial backup";
	#rsync -avzhe ssh --progress --delete --max-size='10000k' --exclude-from 'exclude_list.txt' / $location;
	echo -e "\nInitial backup complete!";

elif [ "$options" = "Schedule_Backup" ]; then
	if ask "Would you like to schedule backups to the location previously specified?"; then
		echo $location;
	else
		read -p "Enter the ABSOLUTE path for the backup to be stored " location;
		echo $location >> exclude_list.txt;

		# Making the backup directory in case it doesn't exist already
		mkdir -p $location;
	fi

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
elif [ "$options" = "Restore" ]; then
	rsync -avr * $location;
elif [ "$options" = "Quit" ]; then
	exit;
else
	echo "Please select a valid option";
fi
done

#user@83.212.127.62:/home/user/backup

# Removing the user defined path from the exclude list
head -n -1 exclude_list.txt > temp.txt
mv temp.txt exclude_list.txt