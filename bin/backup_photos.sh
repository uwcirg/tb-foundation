docker run -it --rm --env-file .env --entrypoint=/bin/sh minio/mc -c '
echo "Loading Minio Settings"
mc alias set local_minio $URL_MINIO $MINIO_ACCESS_KEY $MINIO_SECRET_KEY;
mc ls local_minio;
mc 
'