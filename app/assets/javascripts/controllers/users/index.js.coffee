Twitarr.UsersIndexController = Twitarr.ObjectController.extend
  unlock: (username) ->
    $.ajax(type: 'POST', url: 'admin/activate', data: { username: username }).done (data) =>
      if data.status is 'ok'
        user = _(@get('model').users).find((x) -> x.username is username)
        user.set('status', 'active')
      else
        alert data.status
