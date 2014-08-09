Twitarr.Router.map ()->
  @resource 'seamail', ->
    @route 'detail', { path: ':id' }

  @resource 'forums', ->
    @route 'detail', { path: ':id' }

  @resource 'stream', ->
    @route 'page', { path: ':page' }
    @route 'new'

#  @route 'create_announcement'
#  @resource 'user', ->
#    @route 'change_password'
#    @route 'profile'
#  @resource 'users', ->
#    @route 'index'
#    @route 'edit', { path: '/:username/edit' }
#    @route 'new'
