export PYTHONPATH=$PYTHONPATH:$PWD/src:$PWD/src/apps

HOST=0.0.0.0:8888

if [ "$PLANT_WEBAPP_ENV" == "dev" ] || [ "$PLANT_WEBAPP_ENV" == "local" ]
then
  echo "Starting dev server at $HOST with $DJANGO_SETTINGS_MODULE"
  ENV=dev bash ./scripts/setup_db.sh 2>/dev/null
  python manage.py migrate
  python manage.py shell_plus createsuperuser --noinput --email "dev@plantgroup.co"  2>/dev/null
  python manage.py runserver $HOST
elif [ "$PLANT_WEBAPP_ENV" == "production" ]
then
  python manage.py migrate
  cd /common
  NODE_PATH=/common/node_modules npm run build
  cd -
  python manage.py collectstatic_js_reverse
  python manage.py collectstatic --no-input
  echo "Starting gunicorn at $HOST with $DJANGO_SETTINGS_MODULE"
  gunicorn settings.wsgi -b 0.0.0.0:8888 --log-file -
else
  echo "Must set PLANT_WEBAPP_ENV to local|dev|production !"
fi
