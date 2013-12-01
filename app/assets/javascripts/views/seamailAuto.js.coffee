Twitarr.SeamailAutoView = Ember.View.extend
  templateName: 'seamailAuto'

  keyPress: (e) ->
    switch e.keyCode
      when 40
        return @moveDown()
      when 38
        return @moveUp()

  moveUp: ->
    if $('.to-autocomplete-item:first').is(':focus')
      $('#to-autocomplete').focus()
    else
      $('.to-autocomplete-item:focus').parent().prevAll('li').first().children('a').focus()
    false

  moveDown: ->
    if $('#to-autocomplete').is(':focus')
      $('.to-autocomplete-item:first').focus()
    else
      $('.to-autocomplete-item:focus').parent().nextAll('li').first().children('a').focus()
    false