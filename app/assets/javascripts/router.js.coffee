Twitarr.Router.map ()->
  @route 'announcements'
  @resource 'posts', ->
    @route 'popular'
    @route 'mine'
    @route 'user', { path: '/user/:user' }
    @route 'search', { path: '/search/:tag' }
  @route 'profile'
  @route 'login'
