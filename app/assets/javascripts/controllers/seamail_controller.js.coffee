Twitarr.SeamailNewController = Twitarr.Controller.extend
  actions:
    new: ->
      users = @get('users').split ' '
      Twitarr.Seamail.new_seamail(users, @get('text')).then((forum) =>
        @set 'users', ''
        @set 'text', ''
        @transitionToRoute 'seamail.detail', forum.id
      , ->
        alert 'Forum could not be added. Please try again later. Or try again somepleace without so many seamonkeys.'
      )

Twitarr.SeamailNewMessageController = Twitarr.Controller.extend
  actions:
    new: ->
      Twitarr.Seamail.new_message(@get('id'), @get('new_message')).then( =>
        @set('new_message', '')
        @transitionToRoute 'seamail.detail', @get('id')
      , ->
        alert 'Message could not be sent! Please try again later. Or try again someplace without so many seamonkeys.'
      )

