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
    @route 'view', { path: 'tweet/:id' }

  @resource 'search', ->
    @route 'results', { path: ':text' }
    @route 'user_results', { path: 'user/:text' }
    @route 'tweet_results', { path: 'tweet/:text' }
    @route 'forum_results', { path: 'forum/:text' }

  @resource 'admin', ->
    @route 'announcements'
    @route 'users'

  @route 'user', { path: 'user/:username' }
  @route 'alerts'
  @route 'profile'