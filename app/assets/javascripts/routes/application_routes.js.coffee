Twitarr.LoadingRoute = Ember.Route.extend
  renderTemplate: ->
    @render 'loading'

Twitarr.ApplicationRoute = Ember.Route.extend
  actions:
    logout: ->
      $.getJSON('user/logout').done (data) =>
        if data.status is 'ok'
          @controller.logout()
          @transitionTo 'stream.index'
    start_upload: ->
      @controller.incrementProperty 'uploads_pending'
    end_upload: ->
      @controller.decrementProperty 'uploads_pending'
    display_photo: (photo) ->
      @controllerFor('photo_view').set 'model', photo
      @render 'photo_view',
        into: 'application',
        outlet: 'modal'
    close_photo: ->
      @disconnectOutlet
        outlet: 'modal',
        parentView: 'application'
    display_seamail: (id) ->
      @transitionTo('seamail.detail', id)
    display_forum: (id) ->
      @transitionTo('forums.detail', id)
    display_tweet: (id) ->
      @transitionTo('stream.view', id)

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.index'

Twitarr.ProfileRoute = Ember.Route.extend
  model: ->
    Twitarr.Profile.get()

Twitarr.AlertsRoute = Ember.Route.extend
  setupController: (controller, model) ->
    controller.set('announcements', [
      Twitarr.Announcement.create(text: "Floggings will continue until morale improves.", author: "Paul & Storm", author_username: 'admin', timestamp: new Date()),
      Twitarr.Announcement.create(text: "I am the very model of the modern major general.", author: "Paul & Storm", author_username: 'admin', timestamp: new Date())
    ])
    controller.set('seamails', [
      Twitarr.SeamailMeta.create(subject: "some subject", timestamp: new Date(), messages: 4, display_names: ['steve', 'dave']),
      Twitarr.SeamailMeta.create(subject: "other subject", timestamp: new Date(), messages: 2, display_names: ['fred', 'barney'])
    ])
    controller.set('tweet_mentions', [
      Twitarr.StreamPost.create(text: "some text", timestamp: new Date(), author: 'steve'),
      Twitarr.StreamPost.create(text: "other text", timestamp: new Date(), author: 'fred')
    ])
    controller.set('forum_mentions', [
      Twitarr.ForumMeta.create(subject: "some text", timestamp: new Date(), posts: '5 posts'),
      Twitarr.ForumMeta.create(subject: "other text", timestamp: new Date(), posts: '7 posts')
    ])

Twitarr.UserRoute = Ember.Route.extend
  model: (params) ->
    params

  setupController: (controller, model) ->
    controller.set('username', model.username)