Twitarr.SeamailNewView = Ember.View.extend

  keyUp: (e) ->
    switch e.keyCode
      when 40
        return @moveDown()
      when 38
        return @moveUp()
      when 27
        @get('controller').send('cancel_autocomplete')
        $('#to-autocomplete').focus()
        return false

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
      $('.to-autocomplete-item:focus').parent().nextAll