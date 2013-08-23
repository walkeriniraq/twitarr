Twitarr.Router.map ()->
  @route 'announcements'
  @route 'admin'
  @resource 'posts', ->
    @route 'popular'
    @route 'mine'
    @route 'user', { path: '/user/:user' }
    @route 'search', { path: '/search/:tag' }
  @route 'profile'
  @route 'login'
