Twitarr.UserChangePasswordController = Twitarr.Controller.extend
  errors: []

  actions:
    change: ->
      params = {}
      params['old_password'] = @get('old_password').trim()
      params['new_password'] = @get('new_password').trim()
      params['new_password2'] = @get('new_password2').trim()
      $.post("user/change_password", params).done (data) =>
        if data.status isnt 'ok'
          alert data.status
        else
          alert 'Password changed successfully.'
          @transitionToRoute('posts.all')
