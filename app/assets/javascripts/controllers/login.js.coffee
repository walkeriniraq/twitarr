Twitarr.LoginController = Twitarr.Controller.extend
  login: ->
    $.post('user/login', { username: @get('username'), password: @get('password') }).done (data) =>
      if data.status is 'ok'
        @get('controllers.application').login data.user
        history.go -1
      else
        alert data.status

  request_account: ->
    $.post(
      'user/new'
      {
        username: @get('new-username')
        email: @get('email')
        password: @get('new-password')
        password2: @get('new-password2')
      }
    ).done (data) =>
      if data.status is 'ok'
        alert "Account has been requested. You should recieve an email with account confirmation in 24-48 hours."
        history.go -1
      else
        alert data.status
