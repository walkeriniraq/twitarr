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
  mts = moment timestamp
  new Ember.Handlebars.SafeString("<span class='timestamp' title='#{mts.format("MMMM Do, h:mm a")}'>#{mts.fromNow(true)} ago</span>")

Ember.Handlebars.helper 'user_picture', (username) ->
  new Ember.Handlebars.SafeString("<img class='profile_photo' src='/api/v2/user/photo/#{username}'/>")
