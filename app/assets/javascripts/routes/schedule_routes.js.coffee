Twitarr.ScheduleLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.ScheduleIndexRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo 'schedule.today'

Twitarr.ScheduleTodayRoute = Ember.Route.extend
  renderTemplate: ->
    @render 'schedule.day', { controller: 'schedule.day' }
  model: ->
    Twitarr.EventMeta.all()

  actions:
    reload: ->
      @transitionTo 'schedule.today'

Twitarr.ScheduleDayRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.EventMeta.all params.page

  actions:
    reload: ->
      @transitionTo 'schedule.today'

Twitarr.ScheduleNewRoute = Ember.Route.extend()

Twitarr.ScheduleDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Event.get params.id

Twitarr.ScheduleEditRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Event.get_edit(params.id)
