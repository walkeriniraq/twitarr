Twitarr.ForumsLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.ForumsPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.ForumMeta.page params.page || 0

  actions:
    reload: ->
      @refresh()

Twitarr.ForumsDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Forum.get params.id, params.page

  actions:
    reload: ->
      @refresh()
