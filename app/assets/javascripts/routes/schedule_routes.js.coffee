Twitarr.ScheduleLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.ScheduleIndexRoute = Ember.Route.extend
  model: ->
    Twitarr.EventMeta.all()

  actions:
    reload: ->
      @refresh()

Twitarr.SchedulePageRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.all params.page

  actions:
    reload: ->
      @transitionTo 'schedule'

Twitarr.ScheduleOldRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.old params.page

  actions:
    reload: ->
      @transitionTo 'schedule'

Twitarr.ScheduleNewRoute = Ember.Route.extend()

Twitarr.ScheduleDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Event.get params.id

Twitarr.ScheduleEditRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Event.get_edit(params.id)
