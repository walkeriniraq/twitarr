Twitarr.UserProfileController = Twitarr.ObjectController.extend
  errors: []
  needs: 'application'

  actions:
    save: ->
      params = {}
      params['display_name'] = (@get('display_name') || '').trim()
      params['security_question'] = (@get('security_question') || '').trim()
      params['security_answer'] = (@get('security_answer') || '').trim()
      $.post("user/profile", params).done (data) =>
        if data.status is 'ok'
          @set('controllers.application.display_name', @get('display_name'))
          @transitionToRoute('posts.all')
        else if data.status is 'error'
          @set('errors', data.errors)
        else
          alert data.status
