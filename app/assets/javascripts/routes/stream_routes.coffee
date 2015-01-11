Twitarr.StreamLoadingRoute = Twitarr.LoadingRoute.extend()

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

  setupController: (controller, model) ->
    controller.set 'model', model
    controller.set 'base_reply_text', "@#{model.author} "
    controller.set 'reply_text', "@#{model.author} "

  actions:
    reload: ->
      @refresh()

mostRecentTime = -> Math.ceil(new Date().valueOf() + 1000)
