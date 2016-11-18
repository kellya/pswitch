#!/bin/bash
PROFILE_KEY='/org/gnome/shell/extensions/desk-changer/current-profile'
#Set binaries (These are probably in your path anyway, but let's be safe)
XDPYINFO='/usr/bin/xdpyinfo'
GREP='/usr/bin/grep'
AWK='/usr/bin/awk'
DCONF='/usr/bin/dconf'

#This gets the screen resolution
function getResolution(){
	#Gets the current screen resolution
	local SCREENRES=$(${XDPYINFO}|${GREP} dimensions|${AWK} '{ print $2 }')
	echo $SCREENRES
}

function getProfile(){
	local CURRENT=$(${DCONF} read $PROFILE_KEY)
	echo $CURRENT
}

function writeProfile(){
	dconf write $PROFILE_KEY $1
	if [ $? -eq 0 ];then
		notify-send "Desktop resolution changed to $1"
	else
		notify-send "Desktop change to $1 failed, setting default"
		dconf write $PROFILE_KEY \'default\'
	fi
}

# Check if we were given any arguments
if [ $# -gt 0 ];then
	case $1 in
		'getres')
			echo $(getResolution)
			;;
		'setprofile')
			writeProfile \'$2\'
			exit 0
			;;
		*)
			echo "I don't know what '$1' means"
			exit 99
			;;
	esac
fi

#Now we just set the profile name based on whatever the screen resolution is
RES=$(getResolution)
case $RES in
	'3840x1080')
		NEWPROFILE="'default'"
		;;
	'1920x1080')
		NEWPROFILE="'laptop_screen'"
		;;
	*)
		echo "Don't have images for $RES resolution"
		;;
esac
#Check if we need to change the profile.  This matters more if you have change background with profile enabled, because you would needlessly change the background on load even though resolution didn't change.
if [ $NEWPROFILE == $(getProfile) ];then
	# They are the same, so nothing needs to change.
	exit 0
else
	# Our screen and profile don't match...let's fix that
	writeProfile $NEWPROFILE
fi
