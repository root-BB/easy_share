#!/bin/sh
#Created by BaHTsIzBEdEvi
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
DEFAULT='\033[0m'
SERVICE=0

#Delete File
remove() {
	while true; do
    		read -p "Are you sure you want to delete the ${file} file permanantly? (yes/no)" answer
    		case ${answer} in
    			[Yy]* ) break;;
        		[Nn]* ) exit;;
        		* ) echo "Please answer yes or no.";;
    		esac
	done
	if ! [ -f "/var/www/html/${file}" ]; then
		printf "${RED}\nCould not find any shared ${file} files!${DEFAULT}\n"
		exit
	fi
	sudo rm /var/www/html/${file}
	printf "${GREEN}\nFile ${file} has been permanently deleted.${DEFAULT}\n"
}

#Usage Error
usage() {
	printf "${GREEN}\nUsage: bash easy_share.sh <parameter>${DEFAULT}\n"
	printf "${BLUE}\t-f/--file <file name>	:	File to open for sharing.${DEFAULT}\n"
	printf "${BLUE}\t-s/--share		:	Open the file to share (used with the -f command).${DEFAULT}\n"
	printf "${BLUE}\t-r/--remove		:	Delete the file in the share (used with the -f command).${DEFAULT}\n"
	printf "${BLUE}\t-o/--open		:	To open the sharing service.${DEFAULT}\n"
	printf "${BLUE}\t-t/--terminate		:	To close the sharing service.${DEFAULT}\n"
	printf "${BLUE}\t-l/--list		:	Listing shared file names.${DEFAULT}\n"
	printf "${BLUE}\t-h/--help		:	To print these usage notes on the screen.${DEFAULT}\n"
}

#Copy File
copy() {
	if ! [ -f "/var/www/html/${file}" ]; then
		while true; do
    			read -p "${RED}\nThere is already a shared file named ${file}, would you like to overwrite it? (yes/no)${DEFAULT}\n" answer
    			case ${answer} in
        			[Nn]* ) exit;;
        			* ) echo "Please answer yes or no.";;
    			esac
		done
	fi
	if ! [ -f "${file}" ]; then
		printf "${RED}\nCouldn't find file ${file}!${DEFAULT}\n"
		exit
	fi
	sudo cp ${file} /var/www/html
	if ! [ -f "/var/www/html/${file}" ]; then
		printf "${RED}\nCopy failed!${DEFAULT}\n"
		exit
	fi
}

#Change Permission
permission() {
sudo chmod 777 /var/www/html/${file} && printf "${GREEN}\nFile permissions changed.${DEFAULT}\n" || printf "${RED}\nCould not change file permissions!${DEFAULT}\n" || exit
}

#Start Apache Service
start_apache() {
	systemctl is-active --quiet apache2 && SERVICE=1
	if ! [ ${SERVICE} = "1" ]; then
		sudo service apache2 start
		systemctl is-active --quiet apache2 && SERVICE=1
		if ! [ ${SERVICE} = "1" ]; then
			printf "${RED}\nService failed to start!${NC}\n"
			exit
			else
				message="Apache service successfully started."
		fi
		else
			message="Apache service already running."
	fi
}

#Stop Apache Service
stop_apache() {
	systemctl is-active --quiet apache2 && SERVICE=1
	if [ ${SERVICE} = "1" ]; then
		sudo service apache2 stop
		SERVICE=0
		systemctl is-active --quiet apache2 && SERVICE=1
		if [ ${SERVICE} = "1" ]; then
			printf "${RED}\nService failed to stop!${NC}\n"
			exit
			else
			message="Apache service successfully terminated."
		fi
		else
		message="Apache service already stopped."
	fi
}

#Show File Share Path
show_shared() {
	IP4=$(/sbin/ip -o -4 addr list tun0 2> /dev/null | awk '{print $4}' | cut -d/ -f1)
	if [[ ${IP4} == "" ]]; then
		IP4=$(/sbin/ip -o -4 addr list eth0 2> /dev/null | awk '{print $4}' | cut -d/ -f1)
		if [[ ${IP4} == "" ]]; then
		printf "${RED}\nCouldn't find address automatically.${DEFAULT}\n"
		printf "${GREEN}File sharing address :${DEFAULT}\n"
		printf "${BLUE}IP/${file}${DEFAULT}\n"
		exit
		fi
	fi
	printf "${GREEN}\nShared files :${DEFAULT}\n"
	printf "${BLUE}${IP4}/${file} ${DEFAULT}\n"
}

#Shared file list
list() {
	printf "${GREEN}Shared files :${DEFAULT}\n"
	ls -R /var/www/html 
}

# Parse flags
while [ $# -gt 0 ]; do
        key="$1"

        case "${key}" in
        -f | --file)
                file="$2"
                if [ ${file} = "" ]; then
			usage
			exit
		fi
                shift
                shift
                ;;
        -f | --file)
                file="$2"
                if [ ${file} = "" ]; then
			usage
			exit
		fi
                shift
                shift
                ;;
        *)
                parameter="$1"
                shift
                ;;
        esac
done


#Command Execution
case "${parameter}" in
        -s | --share)
        	if [ ${file} = "" ]; then
			usage
			exit
		fi
        	copy
        	permission
        	start_apache
        	show_shared
        	exit
        	;;
        -r | --remove)
        	if [ ${file} = "" ]; then
			usage
			exit
		fi
        	remove
        	exit
        	;;
        -o | --open)
                start_apache
                printf "${GREEN}${message}${DEFAULT}\n"
                list
                exit
                ;;
	-t | --terminate)
		stop_apache
		printf "${GREEN}${message}${DEFAULT}\n"
		exit
		;;
        -l | --list) list
        	exit
        	;;
        -H | --help)
        	usage
        	exit
        	;;
       	*)
       		usage
        	exit
        	;;
esac
exit
