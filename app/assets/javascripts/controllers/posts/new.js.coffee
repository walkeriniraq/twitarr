Twitarr.PostsNewController = Twitarr.Controller.extend
  USER_REGEX: /@[\w&-]{1,}$/
  HASHTAG_REGEX: /#[\w&-]{1,}$/

  text: ''
  errors: {}
  searchResults: []

  text_change: (->
    word = @get_current_word()
    unless word
      @set 'searchResults', []
      @last_search = ''
      return
    if word[0] is '@'
      @last_search = word
      $.getJSON("user/autocomplete?string=#{encodeURIComponent word.substr(1)}").then (data) =>
        if @last_search is word
          names = ("@#{name}" for name in data.names)
          @set 'searchResults', names
  ).observes 'text'

  get_current_word: ->
    elt = $('#post-autocomplete')
    return unless elt.length > 0
    val = @get 'text'
    # if we trim here it throws off the cursor position.  :(
    return unless val.length > 0
    cursor_pos = elt.getCursorPosition()
    return if val[cursor_pos - 1] is ' '
    if val.length is cursor_pos || val[cursor_pos] is ' '
      user = @get_user val.substr(0, cursor_pos)
      return user if user
      return @get_hashtag val.substr(0, cursor_pos)
    null

  actions:
    select: (value) ->
      value = value.toString()
      word = @get_current_word()
      if word && word is @last_search
        text = @get('text')
        cursor_pos = $('#post-autocomplete').getCursorPosition()
        if text[cursor_pos] is ' '
          text = text.substr(0, cursor_pos - word.length) + value + text.substr(cursor_pos)
        else
          text = text.substr(0, cursor_pos - word.length) + value + ' '
        Ember.run =>
          @set 'text', text
        $('#post-autocomplete').setCursorPosition(cursor_pos - word.length + value.length)
      @set 'searchResults', []
      @last_search = ''
      $('#post-autocomplete').focus()

    send: ->
      errors = {}
      text = @get('text').trim()
      unless text
        errors = { text: 'Type something before clicking send!' }
      else
        Twitarr.Post.new(text).done (data) =>
          if data.status is 'ok'
            @set 'text', ''
            @transitionToRoute 'posts.feed'
          else
            alert data.status
      @set 'errors', errors

  get_user: (string) ->
    start = string.search @USER_REGEX
    return if start is -1
    return unless start is 0 or string[start - 1] is ' '
    string.substr(start)

  get_hashtag: (string) ->
    start = string.search @HASHTAG_REGEX
    return if start is -1
    return unless start is 0 or string[start - 1] is ' '
    string.substr(start)

