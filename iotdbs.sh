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
		wget -q $RSS_URL
		i=0
		while [[ ! $(head -1 ./$RSS | grep xml | wc -l)  ]] && [ $i -lt 10 ]; do
			rm ./$RSS
			sleep 1
			wget -q $RSS_URL
			let i=i+1
			echo $i 
		done

		if [[ $(cat ./$RSS | grep xml | wc -l) ]]; then
			$(cat ./$RSS | grep -o '<enclosure [^>]*>' | grep -o 'http://[^\"]*' | head > img.list)

			# If pictures already exists, don't need to waste the bandwidth
			if [ $(ls -A $HOME/.wallpapers/ | wc -l) -lt 1 ]; then
				wget -q -i img.list -P $HOME/.wallpapers
			else
				rm $HOME/.wallpapers/{*.jpg.*,*.jpeg.*}
			fi
			# The directory already exists ?
			mkdir -p $HOME/.wallpapers

			rm ./$RSS
			rm img.list
			if [ $(ls -A $HOME/.wallpapers/ | wc -l ) -gt 1 ]; then
				feh --bg-scale --randomize $HOME/.wallpapers/
				echo "Done step 2"
				rm $RUN
			else
				echo "Step 2 failed. Can't find any pictures in the $HOME/.wallpapers/ folder."
			fi
		else
			echo -e "\n --->" $(date) "\n" "\e[41;1mStep 2 failed. The RSS file can't be read. The script tried 10 times.\e[0m\n" >> $LOG
			echo -e "\e[41;1mStep 2 failed.\e[0m The RSS file can't be read. The script tried 10 times."
			echo "Please read the log file, if everything is ok : restart the script."
			echo -e "You will find the log there :" "\e[104;1m$(ls $LOG)\e[0m"
		fi

}

#############
# Mode auto #
#############
auto(){
	counter=0
	while [ $(ls -A $HOME/.wallpapers/ | wc -l ) -gt 1 ]; do
		sleep "$TIME"m
		feh --bg-scale --randomize $HOME/.wallpapers/
		let counter=counter+1
		if [ $counter -gt 24 ]; then
			# rm -rf $HOME/.wallpapers/
			echo "The script has loaded "$counter" times images. Let's some new pictures"
			echo -e "\n --->" $(date) "\n" "\e[32;1mThe script has loaded "$counter" times images. Let's some new pictures" >> $LOG
			previous
		fi
	done
}
####################
# Looking for args #
####################
prefix=
key=
value=
for arguments in "$@"
do
  case "${prefix}${arguments}" in
    -s=*|--size=*)  key="-s";     value="${arguments#*=}";; 
    -rss=*|--rss_url=*)      key="-rss";    value="${arguments#*=}";;
    -t=*|--time=*)    key="-t";     value="${arguments#*=}";;
	-h|--help) key="-h";;
    *)   value=$arguments;;
  esac
  case $key in
    -s) if [[ ${value} == "normal" ]]; then
    	SIZE=i
    elif [[ ${value} == "large" ]]; then
    		SIZE=lg_i
    fi;
    prefix=""; key="";SIZE_VALUE="${value}" ;;
    -rss) RSS_URL="${value}";          prefix=""; key="";;
    -t)  TIME="${value}";           prefix=""; key="";;
	-h)  SHOW_HELP=1;           prefix=""; key="";;
    *)   prefix="${arguments}=";;
  esac
done 
# If nothing was given, default args will be loaded
if [[ -z "$SIZE" ]]
	then
		SIZE=lg_i
		SIZE_VALUE=large
fi
if [[ -z "$RSS" ]]
	then
		RSS_URL=http://www.nasa.gov/rss/dyn/"$SIZE"mage_of_the_day.rss
		RSS="$SIZE"mage_of_the_day.rss
fi
if [[ -z "$TIME" ]]
	then
		TIME=30
fi
# User asking for help
show_Help(){
	echo -e "\nUtilisation :\n"
	echo -e "	iotdbs -s <\e[33mnormal/large\e[0m> -rss <\e[34murl\e[0m>"
	echo
	echo "Options :"
	echo " -s 	Select the size/quality of the pictures. Depends of your connection."
	echo -e " 	'\e[33mnormal\e[0m' is the default argument"
	echo -e " 	'\e[33mlarge\e[0m' is for pictures a bit heavier >2Mo"
	echo -e " -rss 	Add your own <\e[34mRSS url\e[0m>. Default argument is the NASA's image of the day RSS url"
	echo " -h 	Show this message"
}
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
SHOW_HELP=

# First of all, let's check if the script is currently running and the script folder exists
$(mkdir -p $FOLDER)


if [[ ! -e $RUN ]]
	then # Ok, The script isn't currently running
		RUN_CHECKED=1
		echo > $RUN
		echo "#################################################" > $LOG
		echo -e "\n --->" $(date) "\n" "\e[32;1mLaunching the script ...\e[0m" >> $LOG
		echo -e "\n --->" $(date) "\n" "time is : \e[1m" $TIME "\e[0m, size is : \e[1m" $SIZE_VALUE "\e[0mand rss_url is : \e[1m" $RSS_URL "\e[0m" >> $LOG
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
    	$(sleep 1)
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

if [[ $SHOW_HELP == 1 ]]; then
	show_Help
else
	echo "--"
	echo "In order to apply what you want."
	echo "The script has taken the followings arguments :"
	echo -e "\n --->" $(date) "\n" 
	echo -e "  Time : \e[1m"$TIME"\e[0m min"
	echo -e "  Size is : \e[1m"$SIZE_VALUE"\e[0m"
	echo -e "  Rss url is : \e[1m"$RSS_URL "\e[0m\n"
	echo "If you want to change some settings, please check $0 -h or $0 --help."
	echo "--"
	echo "Processing step 1 : Checking environement..."
	previous
	auto
	rm $RUN
fi

# clear
# exit 0
