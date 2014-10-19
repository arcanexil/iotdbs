#  iotdbs.sh
#  
#  Copyright 2014 arcanexil <lucas.ranc@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

# Changelog :
#
# 2014-10-19  arcanexil  <lucas.ranc@gmail.com>
#
#  * Added the feature : arguments lookup, and help through -h
#  * Design and create the two steps : previous() and iotdbs()
#  * Creating the file iotdbs.sh
#

#!/bin/bash

#####################
# The script itself #
#####################
iotdbs(){
	echo "Processing step 2 : Get the content..."
		$(wget -q $RSS_URL)
		i=0
		while [[ ! $(head -1 ./$RSS | grep xml | wc -l) && $i<=5 ]]; do
			rm ./$RSS
			$(wget -q $RSS_URL)
			i=$(($i+1))
			echo $i
		done
		
		if [[ $(more ./$RSS | grep xml | wc -l) ]]; then
			$(more ./$RSS | grep -o '<enclosure [^>]*>' | grep -o 'http://[^\"]*' | head > img.list)
			
			# If pictures already exists, don't need to waste the bandwidth
			if [[ ! -n $(ls $HOME/.wallpapers/*.jpg) ]]; then
				$(wget -q -i img.list -P $HOME/.wallpapers)
			else
				rm $HOME/.wallpapers/*.jpg.* 2> /dev/null
			fi
			# The directory already exists ?
			mkdir -p $HOME/.wallpapers

			rm ./$RSS
			rm img.list
			if [[ -n $(ls $HOME/.wallpapers/*.jpg) ]]; then
				feh --bg-scale --randomize $HOME/.wallpapers/
				echo "Done step 2"
				rm $RUN
			else
				echo "Step 2 failed. Can't find any pictures in the $HOME/.wallpapers/ folder."
			fi
		else
			echo -e "\n --->" $(date) "\n" "\e[41;1mStep 2 failed. The RSS file can't be read. The script tried 5 times.\e[0m"
			echo "Step 2 failed. The RSS file can't be read. The script tried 5 times."
			echo "Please read the log file, if everything is ok : restart the script."
			echo -e "You will find the log there :" "\e[104;1m$(ls $LOG)\e[0m"
		fi
		
	
}

#############
# Mode auto #
#############
auto(){
	counter=0
	while [[ -n $(ls $HOME/.wallpapers/*.jpg) ]]; do
		feh --bg-scale --randomize $HOME/.wallpapers/
		sleep "$TIME"m
		counter=$(($counter+1))
		if [[ $counter==24 ]]; then
			rm -rf $HOME/.wallpapers/
			previous
		fi
	done
}
####################
# Looking for args #
####################
# Check if the "first" args is -s <size>.
# If so, we can load the size.
if [[ "$1" == '-s' ]]
then
	[ -z "$2" ] 
	if [[ $2 == "normal" ]]
	then
		SIZE="i"
	elif [[ $2 == "large" ]]
	then
		SIZE="lg_i"
	fi
fi
# Check if the "second" args is -rss <RSS url>.
# If so, we can load the RSS url : obviouly RSS implementation can change at any time.
if [[ "$3" == '-rss' ]]
then
	[ -z "$4" ] 
	if [[ $4 =~ ^http:// ]]
	then
		RSS="$4"
	fi
fi

# Check if the "third" args is -t <time> in minutes.
# If so, we can load the RSS url : obviouly RSS implementation can change at any time.
if [[ "$5" == '-t' ]]
then
	[ -z "$6" ] 
	if [[ $6 == *[[:digit:]]* ]]
	then
		TIME="$6"
	fi
fi
# If no rss and size given, default args will be loaded
if [[ -z "$SIZE" ]]
	then
		SIZE=lg_i
fi
if [[ -z "$RSS" ]]
	then
		RSS_URL=http://www.nasa.gov/rss/dyn/"$SIZE"mage_of_the_day.rss
		RSS="$SIZE"mage_of_the_day.rss
fi
if [[ -z "$TIME" ]]
	then
		TIME=1
fi
# User asking for help
if [[ "$1" == '-h' ]]
then
	echo -e "\nUtilisation :\n"
	echo -e "	iotdbs -s <\e[33mnormal/large\e[0m> -rss <\e[34murl\e[0m>"
	echo
	echo "Options :"
	echo " -s 	Select the size/quality of the pictures. Depends of your connection."
	echo -e " 	'\e[33mnormal\e[0m' is the default argument"
	echo -e " 	'\e[33mlarge\e[0m' is for pictures a bit heavier >2Mo"
	echo -e " -rss 	Add your own <\e[34mRSS url\e[0m>. Default argument is the NASA's image of the day RSS url"
	echo " -h 	Show this message"
fi
############################################################################
# Just in case, let's insure the conditions are good to execute the script #
############################################################################
previous(){
# We need some variables (it's optional but faster to write for me )
FOLDER=$HOME/.iotdbs
LOG=$HOME/.iotdbs/script.log
RUN=$HOME/.iotdbs/script-running
# ECHO=$(echo -e "\n --->" $(date) "\n") ------------------- -> TODO : find why it's not working
RUN_CHECKED=
DISPLAY_CHECKED=
NETWORK_ALIVE=
NETWORK_CHECKED=

# First of all, let's check if the script is currently running and the script folder exists
$(mkdir -p $FOLDER)


if [[ ! -e $RUN ]]
	then # Ok, The script isn't currently running
		RUN_CHECKED=1
		echo > $RUN
		echo "#################################################" > $LOG
		echo -e "\n --->" $(date) "\n" "\e[32;1mLaunching the script ...\e[0m" >> $LOG
		echo -e "\n --->" $(date) "\n" "\e[32;1mThe script isn't running somewhere else\e[0m" >> $LOG
	else # erf, script already running
		RUN_CHECKED=0
		echo -e "\n --->" $(date) "\n" "Wait! \n\e[41;1mIt looks like the script is currently running somewhere else!\e[0m" > $LOG
fi

# Secondly, test if we could reach the X11 display
if [[ $(ps ax | grep X11) != "" ]]
   then # Display is on -> we can continue
      DISPLAY_CHECKED=1
      echo -e "\n --->" $(date) "\n" "\e[32;1mDisplay is on\e[0m" >> $LOG
   else # Display is off -> erf no display ? 
      DISPLAY_CHECKED=0
      echo -e "\n --->" $(date) "\n" "\e[41;1mDisplay is off\e[0m" >> $LOG
fi

# And thirdly, looking for network connection. Otherway it could not start
if [[ $NETWORK_ALIVE == "" ]]
	then
    	NETWORK_ALIVE=$(ping -c1 google.com 2>&1 | grep unknown)
    	$(sleep 5)
fi

if [[ "$NETWORK_ALIVE" == ""  ]] # If the process succeed all the steps, the script can start
	then
		echo -e "\n --->" $(date) "\n" "\e[32;1mNetwork connection looks good\e[0m" >> $LOG
		echo "#################################################" >> $LOG
		NETWORK_CHECKED=1
	    echo "Done step 1"
	    if [[ $RUN_CHECKED == 1 && $DISPLAY_CHECKED == 1 && $NETWORK_CHECKED == 1 ]]; then
			iotdbs
		else
			echo -e "\e[41;1Step 1 Failed\e[0m"
		fi
	else
		NETWORK_CHECKED=0
		echo -e "\n --->" $(date) "\n" "\e[41;1mCan't reach the network connection\e[0m" >> $LOG
		echo -e "\e[41;1mStep 1 Failed\e[0m"
		echo -e "\e[41;1mSkipping Step 2\e[0m"
fi

# If something went wrong, the user will get this message
if [[ $RUN_CHECKED == 0 || $DISPLAY_CHECKED == 0 || $NETWORK_CHECKED == 0 ]]; then
	echo -e "\e[1mSomething went wrong\e[0m during the process, please check the log."
	echo -e "The log is there :" "\e[104;1m$(ls $LOG)\e[0m"
fi
}

######################################
# Load each steps in the right order #
######################################
if [[ ! "$1" == '-h' ]]
	then
		echo "Processing step 1 : Checking environement..."
		previous
		auto
fi
# clear
# exit 0