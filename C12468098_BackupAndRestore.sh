# Brian Briscoe
# C12468098
# Sat 4 April 2015
# Software Installation and Maintenance
# Assignment 1
# Backup and Restore script

#!/bin/bash

# This function is used to validate yes or no answers inputted by the user
# References: https://gist.github.com/davejamesmiller/1965569
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

# This function adds the cron job to the cron table. The frequency of the cron job running is
# based on the value of the parameter passed into the function
add_cron()
{
	crontab -l | { cat; echo "$1 rsync -avbzhe ssh --delete --progress --max-size='10000k' --exclude-from 'exclude_list.txt' / user@snf-33535.vm.okeanos-global.grnet.gr:$location;"; } | crontab -;
}

choices="Full_Backup Incremental_Backup Schedule_Backup View_Scheduled_Backups Restore_Most_Recent_Backup Quit"

select options in $choices; do
if [ "$options" = "Full_Backup" ]; then

	# This line calls the get_path function to check if the path has already been set by the user.
	# If it hasn't then the user will be prompted to enter it. If it has then the user will be 
	# asked if they wish to use the same location again, if they select no, then they will be prompted
	# to enter it again
	location=`get_path $location`;

	# Adding the path to the exclude list to avoid an infinite loop
	# This is necessary as the I am backing the files up to the cloud virtual machine that I am running the
	# scripts from
	echo $location >> exclude_list.txt;

	# Making the backup directory in case it doesn't exist already
	mkdir -p $location;

	echo "Starting intial backup";
	rsync -avzhe ssh --progress --delete --max-size='10000k' --exclude-from 'exclude_list.txt' / user@snf-33535.vm.okeanos-global.grnet.gr:$location;
	echo -e "\nInitial backup complete!";

elif [ "$options" = "Incremental_Backup" ]; then

	location=`get_path $location`;

	# Adding the path to the exclude list to avoid an infinite loop
	echo $location >> exclude_list.txt;

	# Making the backup directory in case it doesn't exist already
	# This is necessary as the I am backing the files up to the cloud virtual machine that I am running the
	# scripts from
	mkdir -p $location;

	echo "Starting incremental backup";
	rsync -abvzhe ssh --progress --delete --max-size='10000k' --exclude-from 'exclude_list.txt' / user@snf-33535.vm.okeanos-global.grnet.gr:$location;
	echo -e "\nIncremental backup complete!";

elif [ "$options" = "Schedule_Backup" ]; then

	location=`get_path $location`;

	# Adding the path to the exclude list to avoid an infinite loop
	# This is necessary as the I am backing the files up to the cloud virtual machine that I am running the
	# scripts from
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
	# This line shows all the cronjobs which involve rsync
	crontab -l | grep rsync;
elif [ "$options" = "Restore_Most_Recent_Backup" ]; then

	location=`get_path $location`
	
	rsync -abvzhe --progress --delete --max-size='10000k' --exclude-from 'exclude_list.txt' user@snf-33535.vm.okeanos-global.grnet.gr:$location /;

	echo "Most recent backup restored"
elif [ "$options" = "Quit" ]; then
	exit;
else
	echo "Please select a valid option";
fi
done
