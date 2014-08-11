Twitarr.UsersEditController = Twitarr.BaseUsersController.extend
  actions:
    save: ->
      @get('model').save().success (data) =>
        @transitionToRoute 'users.index' if data.status is 'ok'
