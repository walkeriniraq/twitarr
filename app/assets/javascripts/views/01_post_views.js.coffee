Twitarr.BasePostsView = Ember.View.extend
  TIMER_LENGTH: 600
  SCROLL_DISTANCE: 80
  scroll_distance: 0
  is_checking: false

  display_scroll_style: (->
    "height: #{@get('scroll_distance')}px;"
  ).property('scroll_distance')

  max_distance: (->
    @get('scroll_distance') >= @SCROLL_DISTANCE
  ).property('scroll_distance')

  willDestroyElement: ->
    @_super()
    @clearBindings()

  loading_observer: (->
    # this is needed to provide a closure over the correct this reference
    touch_end = =>
      clearTimeout(@timeout)
      if @get('scroll_distance') > @SCROLL_DISTANCE
        Ember.run.debounce(@get('controller'), @get('controller').checkNew, 500, true)
        @set('is_checking', true)
      if @get('scroll_distance') > 0
        @timeout = setTimeout =>
          @set('is_checking', false)
          @timeout = null
          @set('scroll_distance', 0)
        , @TIMER_LENGTH

    touch_move = (evt) =>
      return unless $(window).scrollTop() == 0
      return if $('.navbar-fixed-top .navbar-collapse').is(':visible')
      if @loc == null
        @loc = evt.originalEvent.changedTouches[0].screenY
        return
      loc_diff = evt.originalEvent.changedTouches[0].screenY - @loc
      return unless loc_diff > 0
      @set('scroll_distance', loc_diff)
      evt.preventDefault() #chrome for android does some really odd things when this is not called
    touch_start = (evt) =>
      if $(window).scrollTop() != 0
        @loc = null
      else
        @loc = evt.originalEvent.changedTouches[0].screenY

    if @get 'controller.loading'
      @clearBindings()
    else
      $(document).bind "touchmove", touch_move
      $(document).bind "touchstart", touch_start
      $(document).bind "touchend", touch_end
  ).observes 'controller.loading'

  clearBindings: ->
    $(document).unbind "touchmove"
    $(document).unbind "touchstart"

Twitarr.PostsFeedView = Twitarr.BasePostsView.extend()
Twitarr.PostsPopularView = Twitarr.BasePostsView.extend()
Twitarr.PostsAllView = Twitarr.BasePostsView.extend()
Twitarr.PostsUserView = Twitarr.BasePostsView.extend()
Twitarr.PostsSearchView = Twitarr.BasePostsView.extend()
