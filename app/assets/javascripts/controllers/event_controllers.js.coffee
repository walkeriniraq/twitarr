Twitarr.EventsPageController = Twitarr.ObjectController.extend
  past_events_page: (->
    @get('page') < 0
  ).property('page')

  actions:
    next_page: ->
      @transitionToRoute 'events.page', @get('page') + 1
    prev_page: ->
      @transitionToRoute 'events.page', @get('page') - 1
