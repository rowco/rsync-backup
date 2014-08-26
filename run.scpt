on run argv

    -- many variables
    set remote_ip to item 1 of argv
    set remote_path to  "/net/" & remote_ip & item 2 of argv

    set home to path to home folder
    set home_path to POSIX path of home
    set filter_path to "rsync.filter"
    set log_path to "rsync.log"

    -- command sections

    set long_date to do shell script "date +'%Y-%m-%d %H:%M'"
    set short_date to do shell script "date +%Y-%m-%d"
    set args to " -a --progress --delete --no-g"
    set log_args to " --log-file=" & log_path
    set filter_args to " --filter='merge " & filter_path & "'"
    set path_args to " --link-dest=" & remote_path & "/current " & home_path & "/ " & remote_path & "/backup-" & short_date

    -- put it together

    set command to "rsync" & args & log_args & filter_args & path_args

    -- give time for networking to be activated after sleep

    if ( count argv ) is 3 then
        delay 30
    end if

    log long_date & ": Starting"

    -- ping to see if the server is avaialble, die silently

    try
        set pingresult to do shell script "ping -t 1 -c 1 " & remote_ip
    on error
        log long_date & ": Backup attept failed: ping failed"
        error
    end try

    -- test the mount dir exists, mkdir if not
    do shell script "test -d " & remote_path & " || mkdir " & remote_path

    -- now run rsync, and catch any errors

    set err_code to "None"
    try
        log long_date & ": Running rsync - " & command
        do shell script command
    on error errMsg
        log long_date & ": rsync failed - " & errMsg
        display notification "Backup Failed, will retry later" with title "backups"
        return
    end try

    -- remove the 'current' dir
    try
        do shell script "rm -rf " & remote_path & "/current"
    on error errMsg
        log long_date & ": rm current failed - " & errMsg
    end try

    -- relink to the latest dir
    try
        do shell script "cd " & remote_path & "; ln -s backup-" & short_date & " current"
    on error errMsg
        log long_date & ": ln current failed - " & errMsg
    end try

    display notification "Backup Successful" with title "backups"

    log long_date & ": Finished"
end run
