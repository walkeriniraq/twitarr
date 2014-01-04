Twitarr.Router.map ()->
  @route 'create_announcement'
  @resource 'users', ->
    @route 'index'
    @route 'edit', { path: '/:username/edit' }
    @route 'reset_password', { path: '/:username/reset_password' }
    @route 'new'
  @resource 'posts', ->
    @route 'popular'
    @route 'all'
    @route 'feed'
    @route 'new'
    @route 'user', { path: '/user/:user' }
    @route 'search', { path: '/search/:tag' }
  @resource 'seamail', ->
    @route 'new'
    @route 'inbox'
    @route 'archive'
    @route 'outbox'
  @route 'profile'
  @route 'login'
