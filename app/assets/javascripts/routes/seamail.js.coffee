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
  redirect: ->
    @transitionTo 'seamail.page', 1
