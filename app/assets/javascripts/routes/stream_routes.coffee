Twitarr.StreamIndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.page', new Date().valueOf()

Twitarr.StreamPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.StreamPost.page params.page

  actions:
    reload: ->
      @transitionTo 'stream.page', new Date().valueOf()

