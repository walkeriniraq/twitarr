Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  login_admin: false
  email_count: 0
  posts_count: 0
  display_name: null
  read_only: false
  uploads_pending: 0

  has_uploads_pending: (->
    @get('uploads_pending')
  ).property('uploads_pending')

  init: ->
    $.ajax('user/username', dataType: 'json', cache: false).done (data) =>
      if data.status is 'ok'
        @login data.user
        #        if data.is_read_only
        #          @set 'read_only', true
        if data.need_password_change
          @transitionToRoute('user.change_password')
    # this reloads the page once per day - may solve some javascript issues
    Ember.run.later ->
      window.location.reload()
    , 1000 * 60 * 60 * 24

  actions:
    menu_toggle: ->
      @menu_toggle()

    menu_close: ->
      @menu_toggle()

    login: ->
      window.location = '/login'

  menu_toggle: ->
    $('#side-menu').animate { width: 'toggle' }, 100

  login: (user) ->
    @set 'login_user', user.username
    @set 'login_admin', user.is_admin
    @set 'display_name', user.display_name
#    @tick()

  logout: ->
    @set 'login_user', null
    @set 'login_admin', false
    @set 'display_name', null

#  tick: ->
#    return if @get('read_only')
#    $.ajax('user/update_status', dataType: 'json', cache: false).done (data) =>
#      if data.status is 'ok'
#        @set('email_count', data.new_email)
#        @set('posts_count', data.new_posts)
#        @timer = setTimeout (=> @tick()), 300000

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


Twitarr.PhotoViewController = Ember.Controller.extend
  photo_id: null

  photo_path: (->
    Twitarr.ApplicationController.md_photo_path @get('photo_id')
  ).property('photo_id')

  make_it_work: (->
    "background: url('#{@get('photo_path')}')"
  ).property('photo_path')

  actions:
    open_full: ->
      window.open Twitarr.ApplicationController.full_photo_path(@get('photo_id'))
