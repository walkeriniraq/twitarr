Twitarr.SeamailIndexController = Twitarr.ArrayController.extend
  actions:
    new: ->
      users = @get('users').split ' '
      Twitarr.Seamail.new_seamail(users, @get('text')).then((forum) =>
        @set 'users', ''
        @set 'text', ''
        @pushObject forum
      , ->
        alert 'Forum could not be added. Please try again later. Or try again somepleace without so many seamonkeys.'
      )

Twitarr.SeamailDetailController = Twitarr.ObjectController.extend
  actions:
    new: ->
      Twitarr.Seamail.new_message(@get('id'), @get('new_message')).then((message) =>
        @set('new_message', '')
        @get('messages').pushObject(message)
      , ->
        alert 'Message could not be sent! Please try again later. Or try again someplace without so many seamonkeys.'
      )
