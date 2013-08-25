Twitarr.UsersNewController = Twitarr.BaseUsersController.extend
  add: ->
    @get('model').create_new().success (data) =>
      @transitionToRoute 'users.index' if data.status is 'ok'
