#!/bin/bash
apt-get update && apt-get install -y default-mysql-client

until mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASSWORD}; do
    echo 'waiting for mysqld to be connectable...'
    sleep 3
done

echo "mysqld is connectable."
