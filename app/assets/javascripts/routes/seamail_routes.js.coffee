#Twitarr.SeamailInboxRoute = Ember.Route.extend
#  model: (params) ->
#    params
#  setupController: (controller) ->
#    controller.reload()
#
#Twitarr.SeamailArchiveRoute = Ember.Route.extend
#  model: (params) ->
#    params
#  setupController: (controller) ->
#    controller.reload()
#
#Twitarr.SeamailOutboxRoute = Ember.Route.extend
#  model: (params) ->
#    params
#  setupController: (controller) ->
#    controller.reload()

Twitarr.SeamailIndexRoute = Ember.Route.extend
  model: ->
    Twitarr.SeamailMeta.list()

  actions:
    reload: ->
      @refresh()

Twitarr.SeamailDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Seamail.get params.id

  setupController: (controller, model) ->
    @_super(controller, model)

  actions:
    reload: ->
      @refresh()
