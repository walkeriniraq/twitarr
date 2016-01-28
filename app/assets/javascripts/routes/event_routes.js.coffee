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
    Twitarr.Event.get_edit(params.id)

  setupController: (controller, model) ->
    controller.set 'model', model

Twitarr.EventsNewRoute = Ember.Route.extend()

Twitarr.EventsPastRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.past_page params.page || 0

Twitarr.EventsOwnRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.own_page params.page || 0