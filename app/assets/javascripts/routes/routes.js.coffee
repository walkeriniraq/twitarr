Twitarr.FeedRoute = Ember.Route.extend
  model: ->
    Twitarr.feed_list()

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'announcements'

Twitarr.AnnouncementsRoute = Ember.Route.extend
  model: ->
    Twitarr.BasePost.list('announcements')

Twitarr.MessageRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.create()