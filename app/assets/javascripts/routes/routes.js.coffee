Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'posts.all'
