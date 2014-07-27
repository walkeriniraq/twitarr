Twitarr.StreamIndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.page', mostRecentTime()

Twitarr.StreamPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.StreamPost.page params.page

  actions:
    reload: ->
      @transitionTo 'stream.page', mostRecentTime()

mostRecentTime = -> Math.ceil(new Date().valueOf() / 1000)
