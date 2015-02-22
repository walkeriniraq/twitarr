environment 'production'

directory '/var/www/twitarr'
pidfile 'tmp/puma.pid'
bind 'unix:///var/www/twitarr/tmp/puma.sock'
quiet
threads 0, 16