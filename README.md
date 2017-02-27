# pswitch
This is a script to automatcially change the profile for https://extensions.gnome.org/extension/1131/desk-changer/ extension, based on resolution

## Installation
Just executing the script should do the magic, but if you wish, you may have it auto-run by editing the EXEC path in the desktop_profile.desktop file, and placing desktop_profile.desktop in ~/.config/autostart

## Configuration
### Easy Method
Simply create a profile in the desk-changer plugin configuration that matches your resolution.  You can get your current resolution by running:

	desktop_profile getres

### Marginally more difficult method
If you already have profiles set up and don't want to change the names, you can map them in the script's case statment.  Where there are blocks like:

	'1920x1080')
		NEWPROFILE="'default'"
		;;

Just change the **1920x1080** to whatever your resolution is, and the **default** to your profile name.  If you are adding blocks, be sure to copy the _entire_ condtional block.
