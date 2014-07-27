Twitarr.SeamailDetailController = Twitarr.ObjectController.extend
  actions:
    new: ->
      Twitarr.Seamail.new_message(@get('id'), @get('new_message')).then((message) =>
        @set('new_message', '')
        @get('messages').pushObject(message)
      , ->
        alert 'Message could not be sent! Please try again later. Or try again someplace without so many seamonkeys.'
      )
