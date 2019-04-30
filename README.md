*** Currently Broken - Slack changed from DMG back to zip format - will update soon with logic for both with if then ** 


This script will download a dmg containing the latest version of the Slack app for OS X and install it by placing the app from the downloaded archive in the /Applications directory.

How the script works:

1. Uses curl to download a dmg containing the latest Slack app from OS X from the Slack website into the /tmp directory.

2. Mounts the dmg 

3. Checks whether Slack is running, removes existing Slack app, moves new Slack app from /tmp to /Applications and sets the owner to root:admin

4.Unmounts the Slack dmg Volume 

5. Removes the Slack download dmg  from the /tmp
