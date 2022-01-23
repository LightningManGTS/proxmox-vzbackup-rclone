# proxmox-vzbackup-rclone

This is a vzbackup hook script that backups up your proxmox vms, containers to remote storage such as google drive using proxmox's native vzbackup tool and rclone.

rclone is a command line tool that allows you to sync files from your local disk, to a cloud storage device. 

Backups are stored in the rclone remote and organized into YEAR/MONTH/DAY directories to ease the management of the backup files. The backup script also prunes remote backups after a configurable amount of days. here is also an easy to use script to pull old backups from the remote so that you can restore them like you normally would through the webui or vzdump tool. 

This was built and tested with proxmox-ve-release-7.x  and Pcloud and Google Drive, however it should work with other providers as well. 

## Quickstart

1. SSH or Log into your Proxmox host. Install rclone with `apt-get update;apt-get install rclone;`.
Setup an rclone remote and encrypt that remote if so desired. Further information on configuring rclone can be found here:
 - Adding cloud drive to rclone: https://rclone.org/drive/
 - Encryping your rclone contents: https://rclone.org/crypt/

When setting up the encryption, I DO NOT reccomend you encrypt the filenames and directory names. Doing so will break the ability to easily pull down backups from the remmote.

2. SSH or Log into your Proxmox host as root and clone the repo. I recommend you store it in the `/root` dir so that it also gets backed up.
```
apt-get install git
cd /root
git clone https://github.com/TheRealAlexV/proxmox-vzbackup-rclone.git
chmod +x /root/proxmox-vzbackup-rclone/vzbackup-rclone.sh
```

3. Edit vzbackup-rclone.sh and set `$rclone_disk` `$rclone_path` `$rclone_retention` `$restore_path` at the top of the file. 

4. Open /etc/vzdump.conf, uncomment the `script:` line and set that to `/root/proxmox-vzbackup-rclone/vzbackup-rclone.sh`:
```
script:/root/proxmox-vzbackup-rclone/vzbackup-rclone.sh
```

5. You're finished. Scheduled backup will automatically trigger the rclone backup. To verify this, you can watch the proxmox console log output.

6. You can configure the retention of local backup from the proxmox console.

## Restore old backups

At some point, it'll be very likely that you'll need to pull old backups from your rclone remote that have been removed from the local proxmox server. This can be done by passing the `restore` parameter the date in the format "2022\01\22" or "2022/01/22" and the file to restore to the vzbackup-rclone.sh script:
```
$ ~/proxmox-vzbackup-rclone/vzbackup-rclone.sh restore "2022\01\22" vzdump-qemu-100-2022_01_22-23_41_57.vma.zst
```

You can then do a restore like you normally would from the webui or using the vzdump cli.
