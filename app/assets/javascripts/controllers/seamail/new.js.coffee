Twitarr.SeamailNewController = Twitarr.ObjectController.extend
  searchResults: []

  autoComplete_change: (->
    val = @getAutoCompleteValue()
    return if @current_search is val
    unless !!val
      @set 'searchResults', []
      return
    @current_search = val
    $.getJSON("user/autocomplete?string=#{encodeURIComponent val}").then (data) =>
      if @current_search is val
        @set 'searchResults', data.names
  ).observes('to')

  getAutoCompleteValue: ->
    elt = $('#to-autocomplete')
    return unless elt.length > 0
    val = @get('to')
    cursor_pos = elt.getCursorPosition()
    if (val.length is cursor_pos)
      return val.split(/\s+/).pop()
    if (val[cursor_pos] is ' ')
      prev = val.lastIndexOf(' ', cursor_pos - 1)
      prev = 0 if prev is -1
      return val.substr prev, cursor_pos
    null

  actions:
    select: (name) ->
      values = @get('to').split(/\s+/)
      values = for val in values
        if @current_search is val
          name
        else
          val
      @current_search = values.join(' ') + ' '
      @set 'to', @current_search
      @set 'searchResults', []
      $('#to-autocomplete').focus()

    send: ->
      @set('errors', {})
      errors = @get('model').validate()
      if _.keys(errors).length
        @set('errors', errors)
        return
      @get('model').post().done (data) =>
        unless data.status is 'ok'
          alert data.status
        else
          @transitionToRoute 'posts.feed'
