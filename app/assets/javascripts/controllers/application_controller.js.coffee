Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  login_admin: false
  alerts: false
  display_name: null
  read_only: false
  uploads_pending: 0

  has_uploads_pending: (->
    @get('uploads_pending')
  ).property('uploads_pending')

  setup: (->
    $.ajax('user/username', dataType: 'json', cache: false).done (data) =>
      if data.status is 'ok'
        @login data.user
        if data.need_password_change
          @transitionToRoute('user.change_password')
    # this reloads the page once per day - may solve some javascript issues
    Ember.run.later ->
      window.location.reload()
    , 1000 * 60 * 60 * 24
  ).on('init')

  actions:
    menu_toggle: ->
      @menu_toggle()

    menu_close: ->
      @menu_toggle()

    login: ->
      window.location = '/login'

    help: ->
      window.location = '/help'

  menu_toggle: ->
    $('#side-menu').animate { width: 'toggle' }, 100

  login: (user) ->
    Ember.run =>
      @set 'login_user', user.username
      @set 'login_admin', user.is_admin
      @set 'display_name', user.display_name
    @tick()

  logout: ->
    Ember.run =>
      @set 'login_user', null
      @set 'login_admin', false
      @set 'display_name', null
      @set 'alerts', false
    clearTimeout(@timer)

  tick: ->
    return unless @get('logged_in')
    $.ajax('alerts/check', dataType: 'json', cache: false).done (data) =>
      if data.status is 'ok'
        Ember.run =>
          @set('email_count', data.user.seamail_unread_count)
          @set('posts_count', data.user.unnoticed_mentions)
          @set('alerts', data.user.unnoticed_alerts)
    @timer = setTimeout (=> @tick()), 60000

  logged_in: (->
    @get('login_user')?
  ).property('login_user')

Twitarr.ApplicationController.reopenClass
  sm_photo_path: (photo) ->
    "/photo/small_thumb/#{photo}"

  md_photo_path: (photo) ->
    "/photo/medium_thumb/#{photo}"

  full_photo_path: (photo) ->
    "/photo/full/#{photo}"


Twitarr.PhotoViewController = Twitarr.ObjectController.extend
  photo_path: (->
    if @get('model').get('constructor').toString() == 'Twitarr.User'
      "/api/v2/user/photo/#{@get('username')}?full=true"
    else
      if(@get('animated'))
        Twitarr.ApplicationController.full_photo_path(@get('id'))
      else
        Twitarr.ApplicationController.md_photo_path @get('id')
  ).property('username', 'animated', 'id')

  actions:
    open_full: ->
      if @get('model').get('constructor').toString() == 'Twitarr.User'
        window.open "/api/v2/user/photo/#{@get('username')}?full=true"
      else
        window.open Twitarr.ApplicationController.full_photo_path(@get('id'))

Twitarr.PhotoMiniController = Twitarr.ObjectController.extend
  sm_photo_path: (->
    if(@get('animated'))
      "background: url('#{Twitarr.ApplicationController.sm_photo_path @get('id')}') no-repeat center center black;"
    else
      Twitarr.ApplicationController.sm_photo_path @get('id')
  ).property('photo')

Twitarr.ProfileController = Twitarr.ObjectController.extend
  needs: ['application']

  count: 0

  profile_pic: (->
    "/api/v2/user/photo/#{@get('username')}?bust=#{@get('count')}"
  ).property('username', 'count')

  actions:
    save: ->
      @get('model').save().then (response) =>
        if response.status is 'ok'
          alert 'Profile was saved.'
        else
          alert response.status

    file_uploaded: ->
      @incrementProperty('count')

Twitarr.UserController = Twitarr.Controller.extend()

Twitarr.AlertsController = Twitarr.ObjectController.extend
  reset_alerts: (->
    @set 'controllers.application.alerts', false
  ).on('init')

Twitarr.TagController = Twitarr.Controller.extend()