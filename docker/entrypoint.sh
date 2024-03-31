#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Checking database is running ..."

    while ! nc -z $SQL_HOST $SQL_PORT_PUBLISHED ; do
        sleep 0.1
    done

    echo "Database is up and running :-D"
fi


python manage.py makemigrations
python manage.py migrate
# python manage.py makemigrations --no-input
# python manage.py migrate --no-input
exec "$@"