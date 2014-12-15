Twitarr.Router.map ()->
  @resource 'seamail', ->
    @route 'new_message', { path: ':id/new' }
    @route 'detail', { path: ':id' }
    @route 'new'

  @resource 'forums', ->
    @route 'new_post', { path: ':id/new' }
    @route 'detail', { path: ':id' }
    @route 'new'

  @resource 'stream', ->
    @route 'page', { path: ':page' }
    @route 'new'
    @route 'view', { path: ':id' }

