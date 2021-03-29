#!/bin/sh -e

default_backup_folder=/srv/www/tb-files.cirg.washington.edu/docker/backups
bin_path="$(cd "$(dirname "$0")" && pwd)"
repo_path="${bin_path}/.."
date_stamp=$(date +%Y.%m.%d.%H.%M.%S)
temp_location=/tmp/mc-$date_stamp
backup_folder=${1:-$default_backup_folder}
backup_location=$backup_folder/mc-$date_stamp.tgz

if [ ! -d $temp_location ]; then
  mkdir -p $temp_location
fi

if [ ! -d $backup_folder ]; then
  mkdir -p $backup_folder
fi

cd "${repo_path}"

docker-compose --file=docker-compose.minio-backup.yml run --rm -v $temp_location:/output mc -c \
'
    mc alias set local-minio http://bucket:9000 $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
    mc mirror local-minio /output
'

tar zcvpf $backup_location -C $temp_location .
rm -rf $temp_location

#tar -C argument changes directory so that the folder is not nested within /tmp
#may have side effect of chaning the folder (cd)
#https://stackoverflow.com/questions/5695881/how-do-i-tar-a-directory-without-retaining-the-directory-structure