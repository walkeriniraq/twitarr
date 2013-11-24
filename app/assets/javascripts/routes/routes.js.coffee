Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'feed'

Twitarr.AnnouncementsRoute = Ember.Route.extend
  model: ->
    Twitarr.BasePost.list('announcements')

Twitarr.MessageRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.create()