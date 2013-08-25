Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'announcements'

Twitarr.AnnouncementsRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.list('announcements')

