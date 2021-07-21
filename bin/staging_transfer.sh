#!/bin/sh -e

cd "/srv/www/tb-api.cirg.washington.edu/tb-foundation/bin"
backup.sh || {echo "Backup of prod db failed": exit 1}

restore_file_name="$(ls -t /tmp | grep "tb-v2.sql" | head -n1)"

if [ -z "$restore_file_name"]; then
     >&2 echo "Error: psql dump file not found"
     exit 1
fi

cd "/srv/www/tb-api-staging.cirg.washington.edu/tb-foundation" || { echo "Staging dir not found"; exit 1; } 

if [ "$pwd" != "/srv/www/tb-api-staging.cirg.washington.edu/tb-foundation" ]; then
     >&2 echo "Error: not currently in staging folder. Stoping to prevent prod db damage"
     exit 1
fi

docker stop tb-v2-staging_db_1 || { echo "Stop staging db failed"; exit 1; } 
docker rm tb-v2-staging_db_1  || { echo "Remove staging db failed"; exit 1; } 
docker volume rm tb-v2-staging_postgres-files || { echo "Remove db volume failed"; exit 1; } 

docker-compose up -d || { echo "Error bringing up staging compose services"; exit 1; } 
docker-compose exec db createdb --username webuser production || { echo "Error creating db"; exit 1; } 
docker-compose exec -T db psql --dbname production --username webuser < "/tmp/$restore_file_name" || { echo "Error seeding db"; exit 1; }

docker-compose restart web sidekiq
