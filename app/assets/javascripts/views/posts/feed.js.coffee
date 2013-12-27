Twitarr.PostsFeedView = Ember.View.extend
  TIMER_LENGTH: 600
  scroll_count: 0

  display_scroll_class: (->
    switch @get('scroll_count')
      when 1 then 'scroll-gradient-1'
      when 2 then 'scroll-gradient-2'
      else 'scroll-gradient-3'
  ).property('scroll_count')

  is_checking: (->
    @get('scroll_count') > 2
  ).property('scroll_count')

  check_for_new: (->
    clearTimeout(@timeout)
    console.log 'CHECK FOR NEW ITEMS' if @get('scroll_count') > 2 && !@get('controller.loading')
    if @get('scroll_count') > 0
      @timeout = setTimeout =>
        @timeout = null
        @set('scroll_count', 0)
      , @TIMER_LENGTH
  ).observes('scroll_count', 'controller.loading')

  mouse_scrolled: (evt) ->
    return if evt.deltaY < 0
    return unless $(window).scrollTop() == 0
    @set('scroll_count', @get('scroll_count') + 1)

  loading_observer: (->
    # this is needed to provide a closure over the correct this reference
    mouse_proxy = (evt) =>
      @mouse_scrolled(evt)
    touch_move = (evt) =>
      return unless $(window).scrollTop() == 0
      if @loc == null
        @loc = evt.originalEvent.changedTouches[0].screenY
        return
      loc_diff = evt.originalEvent.changedTouches[0].screenY - @loc
      return unless loc_diff > 0
      @set('scroll_count', Math.ceil(loc_diff / 100))
      evt.preventDefault() #chrome for android does some really odd things when this is not called
    touch_start = (evt) =>
      if $(window).scrollTop() != 0
        @loc = null
      else
        @loc = evt.originalEvent.changedTouches[0].screenY

    if @get 'controller.loading'
      $(window).off "mousewheel"
      $(document).unbind "touchmove"
      $(document).unbind "touchstart"
    else
      $(document).bind "touchmove", touch_move
      $(document).bind "touchstart", touch_start
      $(window).on "mousewheel", mouse_proxy
  ).observes 'controller.loading'