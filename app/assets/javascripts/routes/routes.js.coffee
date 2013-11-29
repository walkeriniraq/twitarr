Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'posts.feed'
