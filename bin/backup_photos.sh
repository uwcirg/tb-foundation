DSTAMP=$(date +%Y.%m.%d.%H.%M.%S)

TEMP_LOCATION=/tmp/mc-$DSTAMP
BACKUP_FOLDER=/Users/kylegoodwin/Desktop/minio-test #Should I let this be an input to the script?
FINAL_LOCATION=$BACKUP_FOLDER/mc-$DSTAMP.tgz

mkdir $TEMP_LOCATION

docker-compose --file=docker-compose.minio-backup.yml \
run --rm \
-v $TEMP_LOCATION:/output \
mc -c '
mc alias set local-minio http://bucket:9000 $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
mc mirror local-minio /output
'
tar zcvpf $FINAL_LOCATION $TEMP_LOCATION
rm -rf $TEMP_LOCATION
find $BACKUP_FOLDER -type f -mtime +7 -exec rm {} \;