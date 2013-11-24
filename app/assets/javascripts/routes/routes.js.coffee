Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'feed'

Twitarr.MessageRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.create()