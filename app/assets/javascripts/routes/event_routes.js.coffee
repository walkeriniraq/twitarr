Twitarr.EventsLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.EventsIndexRoute = Ember.Route.extend
  model: ->
    Twitarr.EventMeta.mine()

  actions:
    reload: ->
      @refresh()

Twitarr.EventsPageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.mine params.page

  actions:
    reload: ->
      @transitionTo 'events'

Twitarr.EventsOldRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.mine_old params.page

  actions:
    reload: ->
      @transitionTo 'events'

