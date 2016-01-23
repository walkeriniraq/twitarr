Twitarr.EventsLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.EventsPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.page params.page || 0

  actions:
    reload: ->
      @refresh()

Twitarr.EventsDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Event.get params.id

Twitarr.EventsEditRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Event.get(params.id)

  setupController: (controller, model) ->
    if(model.status isnt 'ok')
      alert model.status
      return
    controller.set 'model', model.event
