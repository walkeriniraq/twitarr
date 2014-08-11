Twitarr.PostsUserController = Twitarr.BasePostController.extend
  needs: [ 'seamailNew' ]

  user: null

  actions:
    message: (user) ->
      @set('controllers.seamailNew.toPeople', [user])
      @transitionToRoute 'seamail.new'

  get_data_ajax: (info = null) ->
    Twitarr.Post.user(@get('user'), info)
