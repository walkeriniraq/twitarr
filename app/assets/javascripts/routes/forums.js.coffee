Twitarr.ForumsIndexRoute = Ember.Route.extend
  model: ->
    @store.find 'forum_topic'

Twitarr.ForumsDetailRoute = Ember.Route.extend
  model: (params) ->
    @store.find 'forum', params.id
