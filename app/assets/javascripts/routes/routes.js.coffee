Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'feed'
