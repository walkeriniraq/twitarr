Twitarr.UsersResetPasswordController = Twitarr.BaseUsersController.extend
  password: null

  actions:
    change_password: ->
      $.ajax(
        type: 'POST'
        url: 'admin/reset_password'
        data: { username: @get('username'), new_password: @get('password')}
      ).success (data) =>
        unless data.status is 'ok'
          alert data.status
        else
          @transitionToRoute 'users.index'
