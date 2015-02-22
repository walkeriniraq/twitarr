environment 'production'

directory '/var/www/twitarr'
pidfile 'tmp/puma.pid'
bind 'unix://tmp/puma.sock'
quiet
threads 0, 16