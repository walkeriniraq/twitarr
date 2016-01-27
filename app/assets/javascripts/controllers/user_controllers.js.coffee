Twitarr.UserController = Twitarr.ObjectController.extend
  photo_path: (-> "/api/v2/user/photo/#{@get('username')}?full=true").property("username")

  actions:
    star: ->
      @get('model').star()