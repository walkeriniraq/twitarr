Twitarr.EventsLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.EventsPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.page params.page || 0

Twitarr.EventsDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Event.get params.id

  setupController: (controller, model) ->
    controller.set 'model', model

Twitarr.EventsEditRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Event.get(params.id)

  setupController: (controller, model) ->
    if(model.status isnt 'ok')
      alert model.status
      return
    controller.set 'model', model

Twitarr.EventsNewRoute = Ember.Route.extend()