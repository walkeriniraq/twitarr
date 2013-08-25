Twitarr.BaseUsersController = Twitarr.ObjectController.extend
  cancel: -> @transitionToRoute 'users.index'