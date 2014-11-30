Twitarr.SeamailLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.SeamailIndexRoute = Ember.Route.extend
  model: ->
    Twitarr.SeamailMeta.list()

  actions:
    reload: ->
      @refresh()

Twitarr.SeamailDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Seamail.get params.id

  actions:
    reload: ->
      @refresh()

Twitarr.SeamailNewMessageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Seamail.get params.id

  setupController: (controller, model) ->
    controller.set('id', model.id)
    controller.set('subject', model.subject)