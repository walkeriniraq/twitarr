Twitarr.ForumsLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.ForumsIndexRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo 'forums.page', 0

Twitarr.ForumsPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.ForumMeta.page params.page

  actions:
    reload: ->
      @refresh()

Twitarr.ForumsDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Forum.get params.id, params.page

  actions:
    reload: ->
      @refresh()
