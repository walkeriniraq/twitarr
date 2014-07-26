Twitarr.SeamailDetailController = Twitarr.ObjectController.extend
  actions:
    new: ->
      Twitarr.Seamail.new_message(@get('id'), @get('new_message')).then((data) =>
        @set('new_message', '')
        @get('messages').pushObject(Twitarr.SeamailMessage.create(data.seamail_message))
      , ->
        alert 'Message could not be sent! Please try again later. Or try again someplace without so many seamonkeys.'
      )
