Twitarr.ForumsIndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'forums.page', 1
