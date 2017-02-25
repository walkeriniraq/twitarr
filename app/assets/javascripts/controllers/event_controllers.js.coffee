Twitarr.EventsDayController = Twitarr.ObjectController.extend
  today_text: (->
    moment(@get('today')).format('ddd MMM Do')
  ).property('today')
  next_day_text: (->
    moment(@get('next_day')).format('ddd >')
  ).property('next_day')
  prev_day_text: (->
    moment(@get('prev_day')).format('< ddd')
  ).property('prev_day')

  actions:
    next_day: ->
      @transitionToRoute 'events.day', @get('next_day')
    prev_day: ->
      @transitionToRoute 'events.day', @get('prev_day')

Twitarr.EventsTodayController = Twitarr.EventsDayController.extend()
