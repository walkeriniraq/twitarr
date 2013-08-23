Twitarr.LoginController = Twitarr.Controller.extend
  login: ->
    $.post('user/login', { username: @get('username'), password: @get('password') }).done (data) =>
      if data.status is 'ok'
        @get('controllers.application').login data.user
        history.go -1
      else
        alert data.status