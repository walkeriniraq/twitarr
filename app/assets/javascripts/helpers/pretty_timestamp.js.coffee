Ember.Handlebars.helper 'pretty_username', (username, display_name) ->
  if !!display_name
    "#{display_name} (@#{username})"
  else
    '@' + username

Ember.Handlebars.helper 'pretty_timestamp', (timestamp) ->
  new Ember.Handlebars.SafeString("<span class='timestamp' title='#{timestamp}'>#{moment(timestamp).fromNow(true)} ago</span>")

Ember.Handlebars.helper 'user_picture', (username) ->
  new Ember.Handlebars.SafeString("<img src='/api/v2/user/photo/#{username}'/>")
