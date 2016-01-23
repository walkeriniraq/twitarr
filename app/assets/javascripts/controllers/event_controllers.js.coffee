Twitarr.EventsPageController = Twitarr.ObjectController.extend
  # has_next_page: (->
  #   @get('next_page') isnt null or undefined
  # ).property('next_page')

  # has_prev_page: (->
  #   @get('prev_page') isnt null or undefined
  # ).property('prev_page')

  actions:
    # next_page: ->
    #   return if @get('next_page') is null or undefined
    #   @transitionToRoute 'events.page', @get('next_page')
    # prev_page: ->
    #   return if @get('prev_page') is null or undefined
    #   @transitionToRoute 'events.page', @get('prev_page')
    create_event: ->
      @transitionToRoute 'events.new'

Twitarr.EventsMetaPartialController = Twitarr.ObjectController.extend()

Twitarr.EventsDetailController = Twitarr.ObjectController.extend()