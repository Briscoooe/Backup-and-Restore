# Brian Briscoe
# C12468098
# Sat 4 April 2015
# Software Installation and Maintenance
# Assignment 1
# Backup and Restore script

#!/bin/bash

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

# This function checks if the location variable has already been set by the user and if it has
# then the yes/no function is used to ask the user whether or not they would like to use the
# same path again or enter a new one for whatever purpose they need it for
get_path() {

	temp_path=$1

	if [ "$temp_path" != "" ]; then
		if ask "Would you like to use the same path again?"; then
			echo "$temp_path";
		else
			read -p "Enter the ABSOLUTE path for the backup to be stored " path;
			echo "$path";
		fi
	else
		read -p "Enter the ABSOLUTE path for the backup to be stored " path;
		echo "$path";
	fi
}


clear

# This function adds the cron job to the cron table
add_cron()
{
	crontab -l | { cat; echo "$1 rsync -avbzhe --delete --progress --max-size='10000k' --exclude-from 'exclude_list.txt' / $location;"; } | crontab -;
}

choices="Full_Backup Incremental_Backup Schedule_Backup View_Scheduled_Backups Restore_Most_Recent_Backup Quit"

select options in $choices; do
if [ "$options" = "Full_Backup" ]; then

	location=`get_path $location`;

	# Adding the path to the exclude list to avoid an infinite loop
	echo $location >> exclude_list.txt;

	# Making the backup directory in case it doesn't exist already
	mkdir -p $location;

	echo "Starting intial backup";
#	rsync -avzhe --progress --delete --max-size='10000k' --exclude-from 'exclude_list.txt' / $location;
	echo -e "\nInitial backup complete!";

elif [ "$options" = "Incremental_Backup" ]; then

	location=`get_path $location`;

	# Adding the path to the exclude list to avoid an infinite loop
    	echo $location >> exclude_list.txt;

        # Making the backup directory in case it doesn't exist already
        mkdir -p $location;

        echo "Starting incremental backup";
#        rsync -abvzhe --progress --delete --max-size='10000k' --exclude-from 'exclude_list.txt' / $location;
        echo -e "\nIncremental backup complete!";

elif [ "$options" = "Schedule_Backup" ]; then

	location=`get_path $location`;

	echo $location >> exclude_list.txt;

	# Making the backup directory in case it doesn't exist already
	mkdir -p $location;

	echo "How frequently would you like the backup to be performed?"

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
	crontab -l | grep rsync;
elif [ "$options" = "Restore_Most_Recent_Backup" ]; then
	rsync -avr --progress --delete * /;
	echo "Most recent backup restored"
elif [ "$options" = "Quit" ]; then
	exit;
else
	echo "Please select a valid option";
fi
done
