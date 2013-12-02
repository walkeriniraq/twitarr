Twitarr.PostAutoView = Ember.View.extend
  templateName: 'posts/postAuto'

  keyPress: (e) ->
    switch e.keyCode
      when 40
        return @moveDown()
      when 38
        return @moveUp()
      when 27
        @set('controller.searchResults', [])
        return false

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