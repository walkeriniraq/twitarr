Twitarr.UsersIndexController = Twitarr.ObjectController.extend

  actions:
    reset_password: (username) ->
      $.ajax(type: 'POST', url: 'admin/reset_password', data: { username: username }).done (data) =>
        unless data.status is 'ok'
          alert data.status
        else
          alert "#{username}'s password has been reset to 'seamonkey'"

    unlock: (username) ->
      $.ajax(type: 'POST', url: 'admin/activate', data: { username: username }).done (data) =>
        if data.status is 'ok'
          user = _(@get('model').users).find((x) -> x.username is username)
          user.set('status', 'active')
        else
          alert data.status
