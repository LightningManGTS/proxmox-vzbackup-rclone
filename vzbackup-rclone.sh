#!/bin/bash
# ./vzbackup-rclone.sh restore <YYYY/MM/DD> <backed_up_file_in_rclone_disk>

rclone_disk="pcloud"		       # Name of rclone cloud storage 
rclone_path='/My Data/BACKUPDATA/PVE'  # Where you store file inside the cloud storage
rclone_retention=5                     # Retention of files backed up  on the cloud storage
restore_path='/root/RESTORE'	       # Where I restore locally my cloud storage file

#### DO NOT MODIFY UNDER THIS LINE
DEBUG=0				       # Change to 1 to enable
rclone_conf=/root/.config/rclone/rclone.conf
rclone_options="--config $rclone_conf --drive-chunk-size=32M -v --stats=60s --transfers=16 --checkers=16"
timepath="$(date +%Y)/$(date +%m)/$(date +%d)"

COMMAND=${1}
RESTORE_DATE=${2//\\/\/} # format: YYYY/MM/DD or YYYY\MM\DD

#Debug
if [[ ${DEBUG} == '1' ]]; then
        echo "Print Environment: command ${COMMAND} START"
        env
        echo "Print Environment: command ${COMMAND} END"
fi

if [ ! -z "${3}" ];then
        CMDARCHIVE=${3}
fi

if [[ ${COMMAND} == 'restore' ]]; then
    echo "Command: ${COMMAND}"

    [ -d $restore_path ] || mkdir $restore_path
    rclone $rclone_options copy $rclone_disk:"$rclone_path/$RESTORE_DATE/$CMDARCHIVE" $restore_path
    echo "File restored in $restore_path"
fi

if [[ ${COMMAND} == 'job-start' ]]; then
    echo "Command: ${COMMAND}"
    echo "Deleting backups in $rclone_disk:$rclone_path older than $rclone_retention days."
    #Debug
    if [[ ${DEBUG} == '1' ]]; then
    	rclone --dry-run --config $rclone_conf  delete  --min-age d $rclone_retention $rclone_disk:"$rclone_path"
    else
    	rclone --config $rclone_conf  delete  --min-age d $rclone_retention $rclone_disk:"$rclone_path"
    fi
fi

if [[ ${COMMAND} == 'backup-end' ]]; then
    echo "Command: ${COMMAND}"
    echo "Backing up $filename to remote storage"
    rclone $rclone_options copy $TARGET $rclone_disk:"$rclone_path/$timepath"
fi

if [[ ${COMMAND} == 'job-end' ||  ${COMMAND} == 'job-abort' ]]; then
    echo "Command: ${COMMAND}"
fi
