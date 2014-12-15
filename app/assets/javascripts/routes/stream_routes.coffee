Twitarr.StreamLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.StreamRoute = Ember.Route.extend
  actions:
    like: (post) ->
      post.like()
    unlike: (post) ->
      post.unlike()

Twitarr.StreamIndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.page', mostRecentTime()

Twitarr.StreamPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.StreamPost.page params.page

  actions:
    reload: ->
      @transitionTo 'stream.page', mostRecentTime()

Twitarr.StreamViewRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.StreamPost.view params.id

mostRecentTime = -> Math.ceil(new Date().valueOf() + 1000)
