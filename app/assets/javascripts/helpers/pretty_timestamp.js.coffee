Ember.Handlebars.helper 'pretty_timestamp', (timestamp) ->
  new Ember.Handlebars.SafeString("<span class='timestamp'>#{moment(timestamp).fromNow(true)} ago</span>")
