Twitarr.EventsLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.EventsIndexRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo 'events.today'

Twitarr.EventsTodayRoute = Ember.Route.extend
  model: ->
    Twitarr.EventMeta.mine()

  actions:
    reload: ->
      @transitionTo 'events.today'

Twitarr.EventsDayRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.mine params.date

  actions:
    reload: ->
      @refresh()

