rm ~/Library/LaunchAgents/runbackup.plist

launchctl unload runbackup.plist 
launchctl load runbackup.plist 
launchctl start com.launched.backuprun

ln -s `pwd`/runbackup.plist ~/Library/LaunchAgents/runbackup.plist
