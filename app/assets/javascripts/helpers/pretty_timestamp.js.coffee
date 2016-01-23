Ember.Handlebars.helper 'pretty_username', (username, display_name) ->
  if !!display_name && username isnt display_name
    new Ember.Handlebars.SafeString "<span title='@#{username}'>#{display_name}</span>"
  else
    '@' + username

Ember.Handlebars.helper 'display_name_plus_username', (username, display_name) ->
  if !!display_name && username isnt display_name
    "#{display_name} (@#{username})"
  else
    '@' + username

Ember.Handlebars.helper 'pretty_timestamp', (timestamp) ->
  new Ember.Handlebars.SafeString("<span class='timestamp' title='#{timestamp}'>#{moment(timestamp).fromNow(true)} ago</span>")

Ember.Handlebars.helper 'pretty_time', (timestamp) ->
  moment(timestamp).format('lll')

Ember.Handlebars.helper 'pretty_timespan', (start_time, end_time) ->
  if end_time
    new Ember.Handlebars.SafeString("<span class='timestamp'>#{moment(start_time).format('lll')} - #{moment(end_time).format('lll')}</span>")
  else
    new Ember.Handlebars.SafeString("<span class='timestamp'>#{moment(start_time).format('lll')}</span>")


Ember.Handlebars.helper 'user_picture', (username, last_time) ->
  new Ember.Handlebars.SafeString("<img class='profile_photo' src='/api/v2/user/photo/#{username}?bust=#{last_time}'/>")
