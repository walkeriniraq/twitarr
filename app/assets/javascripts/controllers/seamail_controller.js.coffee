Twitarr.SeamailNewController = Twitarr.Controller.extend
  users: ''

  actions:
    new: ->
      users = @get('users').split(/[,\s]/).filter((user) -> !!user)
      Twitarr.Seamail.new_seamail(users, @get('subject'), @get('text')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          return
        @set 'errors', []
        @set 'users', ''
        @set 'subject', ''
        @set 'text', ''
        window.history.go(-1)
      , ->
        alert 'Message could not be sent. Please try again later. Or try again someplace without so many seamonkeys.'
      )

Twitarr.SeamailNewMessageController = Twitarr.Controller.extend
  actions:
    new: ->
      Twitarr.Seamail.new_message(@get('id'), @get('new_message')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          return
        @set('new_message', '')
        @set 'errors', []
        window.history.go(-1)
      , ->
        alert 'Message could not be sent! Please try again later. Or try again someplace without so many seamonkeys.'
      )

