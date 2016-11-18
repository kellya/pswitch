#!/bin/bash
PROFILE_KEY='/org/gnome/shell/extensions/desk-changer/current-profile'
PLUGIN_DIR=~/.local/share/gnome-shell/extensions/desk-changer@eric.gach.gmail.com
#Set binaries (These are probably in your path anyway, but let's be safe)
XDPYINFO='/usr/bin/xdpyinfo'
GREP='/usr/bin/grep'
AWK='/usr/bin/awk'
DCONF='/usr/bin/dconf'
NOTIFY_SEND='/usr/bin/notify-send'

function getResolution(){
	#Gets the current screen resolution
	local SCREENRES=$(${XDPYINFO}|${GREP} dimensions|${AWK} '{ print $2 }')
	echo $SCREENRES
}

function getProfile(){
	#Get the current profile name
	local CURRENT=$(${DCONF} read $PROFILE_KEY)
	echo $CURRENT
}

function writeProfile(){
	#Write out the profile using dconf
	${DCONF} write $PROFILE_KEY $1
	if [ $? -eq 0 ];then
		${NOTIFY_SEND} "Desktop profile changed to $1"
	else
		${NOTIFY_SEND} "Desktop change to $1 failed, setting default"
		${DCONF} write $PROFILE_KEY \'default\'
		#fix code highlighting with this single quote --> '
	fi
}

function printHelp(){
	#Output the helptext
	#todo: fix the formatting so it looks like a real help output
	echo -e "\n$0 - Configure profile for desk-changer gnome-shell extension"
	cat << EOF

Usage: $0 [command]

Commands:
    getRes:  Output the resolution of the current session
      help:  Print this output

    setProfile <profilename>: Will force the profile to <profilename> like:
	                          $0 setProfile default
	    WARNING: This profilename is not validated

Note: You must have the desk-changer extension installed from
      https://extensions.gnome.org/extension/1131/desk-changer/

EOF
}

function verifyInstall(){
	#do various checks to validate things will run correctly
	local RETVAL=0
	if [ ! -d $PLUGIN_DIR ];then
		RETVAL=$((RETVAL+1))
	fi
	echo $RETVAL
}

#Actually verify the installation with the funcion above.
VERIFY=$(verifyInstall)
#If we got an error, print it and die
if [ ! $VERIFY -eq 0 ]; then
	echo -e "Install is invalid.\nGot error code: $VERIFY"
	exit $VERIFY
fi

# Check if we were given any arguments
if [ $# -gt 0 ];then
	case $1 in
		[gG][eE][tT][rR][eE][sS])
			echo $(getResolution)
			;;
		[sS][eE][tT][pP][rR][oO][fF][iI][lL][eE])
			if [ ! -z $2 ];then
				writeProfile \'$2\'
				#fix code highlighting with this single quote --> '
				exit 0
			else
				echo "Error: Must give profile name with $1 command"
			fi
			;;
		*[hH][eE][lL][pP] )
			printHelp
			exit 0
			;;
		*)
			echo "'$1' is not a valid command"
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
#Check if we need to change the profile.  This matters more if you have change
#background with profile enabled, because you would needlessly change the
#background on load even though resolution didn't change.
if [ $NEWPROFILE == $(getProfile) ];then
	# They are the same, so nothing needs to change.
	exit 0
else
	# Our screen and profile don't match...let's fix that
	writeProfile $NEWPROFILE
fi
