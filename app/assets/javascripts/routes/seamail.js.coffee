Twitarr.SeamailNewRoute = Ember.Route.extend
  model: ->
    Twitarr.Seamail.create()

Twitarr.SeamailInboxRoute = Ember.Route.extend
  model: (params) ->
    params
  setupController: (controller) ->
    controller.reload()

Twitarr.SeamailOutboxRoute = Ember.Route.extend
  model: (params) ->
    params
  setupController: (controller) ->
    controller.reload()
