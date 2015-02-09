Twitarr.ForumsLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.ForumsPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.ForumMeta.page params.page

  actions:
    reload: ->
      @refresh()


Twitarr.ForumsRoute = Twitarr.ForumsPageRoute.extend
  model: ->
    Twitarr.ForumMeta.page {page: 0}

Twitarr.ForumsDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Forum.get params.id

  setupController: (controller, model) ->
    controller.set('model', model)

  actions:
    reload: ->
      @refresh()
