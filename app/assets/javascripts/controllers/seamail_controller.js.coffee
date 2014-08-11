Twitarr.SeamailNewController = Twitarr.Controller.extend
  actions:
    new: ->
      users = @get('users').split /[,\s]/
      Twitarr.Seamail.new_seamail(users, @get('subject'), @get('text')).then( =>
        @set 'users', ''
        @set 'subject', ''
        @set 'text', ''
        window.history.go(-1)
      , ->
        alert 'Message could not be sent. Please try again later. Or try again somepleace without so many seamonkeys.'
      )

Twitarr.SeamailNewMessageController = Twitarr.Controller.extend
  actions:
    new: ->
      Twitarr.Seamail.new_message(@get('id'), @get('new_message')).then( =>
        @set('new_message', '')
        window.history.go(-1)
      , ->
        alert 'Message could not be sent! Please try again later. Or try again someplace without so many seamonkeys.'
      )

