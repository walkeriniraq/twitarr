Twitarr.UserRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.User.get(params.username)
