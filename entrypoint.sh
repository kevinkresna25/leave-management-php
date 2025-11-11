#!/bin/bash
set -e

echo "Waiting for database to be ready..."

while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" --ssl-verify-server-cert=false --silent; do
    sleep 1
done
echo "Database is ready."

if [ ! -f "init.lock" ]; then

    echo "First run detected. Running setup..."

    cp src/database_sample.php src/database.php
    echo "Updating database.php with environment variables..."
    sed -i "s/'servername' => DB username/'servername' => '$DB_HOST'/g" src/database.php
    sed -i "s/'database' => Database name/'database' => '$DB_DATABASE'/g" src/database.php
    sed -i "s/'username' => DB username/'username' => '$DB_USERNAME'/g" src/database.php
    sed -i "s/'password' => DB password/'password' => '$DB_PASSWORD'/g" src/database.php

    echo "Installing composer dependencies..."
    composer install && composer dump-autoload

    echo "Running database migration..."
    yes | php migration.php

    echo "Seeding database..."
    yes | php seed.php

    touch init.lock
    echo "Setup complete. init.lock file created."

else
    echo "Setup already completed (init.lock found). Skipping setup."
fi

echo "Starting Apache server..."
exec apache2-foreground