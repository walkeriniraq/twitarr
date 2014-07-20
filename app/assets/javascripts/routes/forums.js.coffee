Twitarr.ForumsIndexRoute = Ember.Route.extend
  model: ->
    @store.find 'forum_topic'

