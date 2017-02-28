Twitarr.Router.map ()->
  @resource 'seamail', ->
    @route 'detail', { path: ':id' }
    @route 'new'

  @resource 'forums', ->
    @route 'page', { path: ':page' }
    @route 'new_post', { path: ':id/new' }
    @route 'detail', { path: 'thread/:id' }
    @route 'detail', { path: 'thread/:id/:page'}
    @route 'new'

  @resource 'stream', ->
    @route 'page', { path: ':page' }
    @route 'star_page', { path: 'star/:page' }
    @route 'new'
    @route 'edit', { path: 'edit/:id'}
    @route 'view', { path: 'tweet/:id' }

  @resource 'search', ->
    @route 'results', { path: ':text' }
    @route 'user_results', { path: 'user/:text' }
    @route 'tweet_results', { path: 'tweet/:text' }
    @route 'forum_results', { path: 'forum/:text' }
    @route 'event_results', { path: 'event/:text' }

  @resource 'admin', ->
    @route 'announcements'
    @route 'upload_schedule'
    @route 'search', { path: 'users' }
    @route 'users', { path: 'users/:text' }

  @resource 'schedule', ->
    @route 'today', { path: 'today' }
    @route 'day', { path: 'day/:date' }
    @route 'new', { path: 'new'}
    @route 'detail', { path: 'event/:id' }
    @route 'edit', { path: 'event/:id/edit'}

  @resource 'events', ->
    @route 'today', { path: 'today' }
    @route 'day', { path: 'day/:date' }

  @route 'user', { path: 'user/:username' }
  @route 'tag', { path: 'tag/:tag_name' }
  @route 'alerts'
  @route 'profile'
  @route 'starred'
  @route 'help'