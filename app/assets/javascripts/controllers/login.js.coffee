Twitarr.LoginController = Twitarr.Controller.extend
  actions:
    login: ->
      $.post('user/login', { username: @get('username'), password: @get('password') }).done (data) =>
        if data.status is 'ok'
          @get('controllers.application').login data.user, data.new_email
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
          @set('username', @get('new-username'))
          @set('new-username', '')
          @set('username', '')
          @set('new-password', '')
          @set('new-password2', '')
          alert "Account has been created. Please login and have fun!"
          history.go -1
        else
          alert data.status
