Twitarr.PostAutoView = Ember.View.extend
  USER_REGEX: /@[\w&-]{1,}$/
  HASHTAG_REGEX: /#[\w&-]{1,}$/

  templateName: 'posts/post_auto'
  searchResults: []

  keyDown: (e) ->
    return true unless $('#post-autocomplete-dropdown').is(':visible')
    switch e.keyCode
      when 40
        @moveDown()
      when 38
        @moveUp()
      when 27
        @set('searchResults', [])
        $('#post-autocomplete').focus()
        false

  text_change: (->
    word = @get_current_word()
    unless word
      @clear_results()
      return
    if word.length <= 1
      @clear_results()
      return
    if word[0] is '@'
      @last_search = word
      $.getJSON("user/autocomplete?string=#{encodeURIComponent word.substr(1)}").then (data) =>
        if @last_search is word
          names = ("@#{name}" for name in data.names)
          @set 'searchResults', names
    if word[0] is '#'
      @last_search = word
      $.getJSON("posts/tag_autocomplete?string=#{encodeURIComponent word.substr(1)}").then (data) =>
        if @last_search is word
          names = ("##{name}" for name in data.names)
          @set 'searchResults', names
  ).observes('controller.text')

  clear_results: ->
    @set 'searchResults', []
    @last_search = ''

  actions:
    select: (value) ->
      value = value.toString()
      word = @get_current_word()
      if word && word is @last_search
        text = @get('controller.text')
        cursor_pos = $('#post-autocomplete').getCursorPosition()
        if text[cursor_pos] is ' '
          text = text.substr(0, cursor_pos - word.length) + value + text.substr(cursor_pos)
        else
          text = text.substr(0, cursor_pos - word.length) + value + ' '
        Ember.run =>
          @set 'controller.text', text
        $('#post-autocomplete').setCursorPosition(cursor_pos - word.length + value.length + 1)
      @clear_results()
      $('#post-autocomplete').focus()

  get_current_word: ->
    elt = $('#post-autocomplete')
    return unless elt.length > 0
    val = @get 'controller.text'
    # if we trim here it throws off the cursor position.  :(
    return unless val.length > 0
    cursor_pos = elt.getCursorPosition()
    return if val[cursor_pos - 1] is ' '
    if val.length is cursor_pos || val[cursor_pos] is ' '
      user = @get_user val.substr(0, cursor_pos)
      return user if user
      return @get_hashtag val.substr(0, cursor_pos)
    null

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

  moveUp: ->
    if $('.post-autocomplete-item:first').is(':focus')
      $('#post-autocomplete').focus()
    else
      $('.post-autocomplete-item:focus').parent().prevAll('li').first().children('a').focus()
    false

  moveDown: ->
    if $('#post-autocomplete').is(':focus')
      $('.post-autocomplete-item:first').focus()
    else
      $('.post-autocomplete-item:focus').parent().nextAll('li').first().children('a').focus()
    false