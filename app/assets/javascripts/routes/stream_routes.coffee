Twitarr.StreamIndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.page', 1

Twitarr.StreamPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.StreamPost.page params.page

  actions:
    reload: ->
      @refresh()

