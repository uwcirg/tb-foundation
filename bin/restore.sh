echo "Stoping Services..."
docker-compose stop web

echo "Dropping current db..."
docker-compose exec db dropdb --username webuser production

echo "Creating empty db..."
docker-compose exec db createdb --username webuser production

echo "Loading SQL dumpfile: ${restore_file_name}..."
docker-compose exec -T db psql --dbname develop --username webuser < "/tmp/$restore_file_name"

echo "Restarting services"
docker-compose up -d