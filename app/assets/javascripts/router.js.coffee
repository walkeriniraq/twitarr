Twitarr.Router.map ()->
  @resource 'seamail', ->
    @route 'detail', { path: ':id' }

  @resource 'forums', ->
    @route 'detail', { path: ':id' }

  @resource 'stream', ->
    @route 'page', { path: ':page' }

#  @route 'start'
#  @route 'create_announcement'
#  @resource 'user', ->
#    @route 'change_password'
#    @route 'profile'
#  @resource 'users', ->
#    @route 'index'
#    @route 'edit', { path: '/:username/edit' }
#    @route 'new'
#  @resource 'posts', ->
#    @route 'popular'
#    @route 'all'
#    @route 'new'
#    @route 'user', { path: '/user/:user' }
#    @route 'tag', { path: '/tag/:tag' }
#  @resource 'seamail', ->
#    @route 'new'
#    @route 'inbox'
#    @route 'archive'
#    @route 'outbox'
