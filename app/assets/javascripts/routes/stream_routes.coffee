Twitarr.StreamLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.StreamIndexRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo 'stream.page', mostRecentTime()

Twitarr.StreamPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.StreamPost.page params.page

  actions:
    reload: ->
      @transitionTo 'stream.page', mostRecentTime()

Twitarr.StreamStarPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.StreamPost.star_page params.page

  actions:
    reload: ->
      @transitionTo 'stream.star_page', mostRecentTime()

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

Twitarr.StreamEditRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.StreamPost.get(params.id)

  setupController: (controller, model) ->
    if(model.status isnt 'ok')
      alert model.status
      return
    controller.set 'model', model.post

mostRecentTime = -> Math.ceil(new Date().valueOf() + 1000)
