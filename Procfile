release: bundle exec rake db:migrate
web: bundle exec thin start -R config.ru -p $PORT -e $RACK_ENV