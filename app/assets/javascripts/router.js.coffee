Twitarr.Router.map ()->
  @route 'announcements'
  @route 'feed'
  @resource 'users', ->
    @route 'index'
    @route 'edit', { path: '/:username/edit' }
    @route 'reset_password', { path: '/:username/reset_password' }
    @route 'new'
  @resource 'posts', ->
    @route 'popular'
    @route 'mine'
    @route 'all'
    @route 'user', { path: '/user/:user' }
    @route 'search', { path: '/search/:tag' }
  @resource 'seamail', ->
    @route 'inbox'
    @route 'outbox'
  @route 'profile'
  @route 'login'
  @route 'message'
