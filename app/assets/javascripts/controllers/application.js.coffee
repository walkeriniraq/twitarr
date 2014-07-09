Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  login_admin: false
  email_count: 0
  posts_count: 0
  display_name: null
  read_only: false

  init: ->
    $.ajax('user/username', dataType: 'json', cache: false).done (data) =>
      if data.status is 'ok'
        @login data.user
#        if data.is_read_only
#          @set 'read_only', true
        if data.need_password_change
          @transitionToRoute('user.change_password')

#  new_email: (->
#    @get('logged_in') && @get('email_count') > 0
#  ).property('logged_in', 'email_count')
#
#  new_posts: (->
#    @get('logged_in') && @get('posts_count') > 0
#  ).property('logged_in', 'posts_count')

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

#  new_email_class: (->
#    if @get('new_email')
#      'new-email-border'
#  ).property('new_email')
#
#  email_count_display: (->
#    if @get('new_email')
#      return @get('email_count')
#    else
#      return null
#  ).property('new_email', 'email_count')
#
#  posts_count_display: (->
#    if @get('new_posts')
#      return @get('posts_count')
#    else
#      return null
#  ).property('new_posts', 'posts_count')
#
#  is_all_users_path: (path) ->
#    return true if path is 'posts.all'
#    return true if path is 'posts.popular'
#    return true if path is 'posts.user'
#    return true if path is 'posts.tag'
#    return true if path is 'search'
#    false
