Twitarr.Router.map ()->
  @resource 'seamail', ->
    @route 'detail', { path: ':id' }
    @route 'new'

  @resource 'forums', ->
    @route 'page', { path: '/' }
    @route 'page', { path: ':page' }
    @route 'new_post', { path: ':id/new' }
    @route 'detail', { path: 'thread/:id' }
    @route 'detail', { path: 'thread/:id/:page'}
    @route 'new'

  @resource 'stream', ->
    @route 'page', { path: ':page' }
    @route 'new'
    @route 'edit', { path: 'edit/:id'}
    @route 'view', { path: 'tweet/:id' }

  @resource 'search', ->
    @route 'results', { path: ':text' }
    @route 'user_results', { path: 'user/:text' }
    @route 'tweet_results', { path: 'tweet/:text' }
    @route 'forum_results', { path: 'forum/:text' }

  @resource 'admin', ->
    @route 'announcements'
    @route 'users'

  @resource 'events', ->
    @route 'page', { path: '/'}
    @route 'page', { path: ':page' }
    @route 'new_event', { path: '/new'}
    @route 'detail', { path: '/event/:id' }
    @route 'edit', { path: '/edit/:id'}


  @route 'user', { path: 'user/:username' }
  @route 'tag', { path: 'tag/:tag_name' }
  @route 'alerts'
  @route 'profile'
  @route 'help'