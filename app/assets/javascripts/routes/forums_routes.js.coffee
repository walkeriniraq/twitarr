Twitarr.ForumsIndexRoute = Ember.Route.extend
  model: ->
    Twitarr.ForumMeta.list()

  actions:
    reload: ->
      @refresh()

Twitarr.ForumsDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Forum.get params.id

  actions:
    reload: ->
      @refresh()

