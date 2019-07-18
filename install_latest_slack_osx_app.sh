#!/bin/bash -v

#if you want slack to quit - in use with a jamf notifcation policy unhash next line
#pkill Slack*

#gets current logged in user
consoleuser=$(ls -l /dev/console | cut -d " " -f4)

APP_NAME="Slack.app"
APP_PATH="/Applications/$APP_NAME"
APP_VERSION_KEY="CFBundleShortVersionString"


DOWNLOAD_URL="https://slack.com/ssb/download-osx"
finalDownloadUrl=$(curl "$DOWNLOAD_URL" -s -L -I -o /dev/null -w '%{url_effective}')
dmgName=$(printf "%s" "${finalDownloadUrl[@]}" | sed 's@.*/@@')
slackDmgPath="/tmp/$dmgName"

################################

#find new version of Slack
currentSlackVersion=$(/usr/bin/curl -s 'https://slack.com/api/desktop.releases.update?platform=darwin&os_version=10.13.5&app_version=0&channel=prod' | grep -o "[0-9]\.[0-9]\.[0-9]" | tail -1)

if [ -d "$APP_PATH" ]; then
    localSlackVersion=$(defaults read "$APP_PATH/Contents/Info.plist" "$APP_VERSION_KEY")
    if [ "$currentSlackVersion" = "$localSlackVersion" ]; then
        printf "Slack is already up-to-date. Version: %s" "$localSlackVersion"
        exit 0
    fi
fi

#find if slack is running
if pgrep '[S]lack'; then
    printf "Error: Slack is currently running!\n"
    exit 409
else

# Remove the existing Application
rm -rf /Applications/Slack.app

#downloads latest version of Slack
curl -L -o "$slackDmgPath" "$finalDownloadUrl"

#mount the .dmg
hdiutil attach -nobrowse $slackDmgPath

#Copy the update app into applications folder
sudo cp -R /Volumes/Slack*/Slack.app /Applications

#unmount and eject dmg
mountName=$(diskutil list | grep Slack | awk '{ print $3 }')
umount -f /Volumes/Slack*/
diskutil eject $mountName

#clean up /tmp download
rm -rf "$slackDmgPath"

# Slack permissions are really dumb
chown -R $consoleuser:admin "/Applications/Slack.app"

localSlackVersion=$(defaults read "$APP_PATH/Contents/Info.plist" "$APP_VERSION_KEY")
    if [ "$currentSlackVersion" = "$localSlackVersion" ]; then
        printf "Slack is now updated/installed. Version: %s" "$localSlackVersion"
    fi
fi

#slack will relaunch if it was previously running
if [ "$slackOn" == "" ] ; then
	exit 0
else
	su - "${consoleuser}" -c 'open -a /Applications/Slack.app'
fi

    exit 0
fi
