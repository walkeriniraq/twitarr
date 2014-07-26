Twitarr.ForumsIndexRoute = Ember.Route.extend
  model: ->
    Twitarr.ForumTopic.list()

  actions:
    reload: ->
      @refresh()

Twitarr.ForumsDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Forum.get params.id

  setupController: (controller, model) ->
    @_super(controller, model)

  actions:
    reload: ->
      @refresh()

