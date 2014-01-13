Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  login_admin: false
  email_count: 0
  posts_count: 0

  init: ->
    $.ajax('user/username', dataType: 'json', cache: false).done (data) =>
      if data.status is 'ok'
        @login data.user

  new_email: (->
    @get('logged_in') && @get('email_count') > 0
  ).property('logged_in', 'email_count')

  new_posts: (->
    @get('logged_in') && @get('posts_count') > 0
  ).property('logged_in', 'posts_count')

  login: (user) ->
    @set 'login_user', user.username
    @set 'login_admin', user.is_admin
    @tick()

  tick: ->
    $.ajax('user/update_status', dataType: 'json', cache: false).done (data) =>
      if data.status is 'ok'
        @set('email_count', data.new_email)
        @set('posts_count', data.new_posts)
        @timer = setTimeout (=> @tick()), 60000

  logged_in: (->
    @get('login_user')?
  ).property('login_user')

  new_email_class: (->
    if @get('new_email')
      'new-email-border'
  ).property('new_email')

  email_count_display: (->
    if @get('new_email')
      return @get('email_count')
    else
      return null
  ).property('new_email', 'email_count')

  posts_count_display: (->
    if @get('new_posts')
      return @get('posts_count')
    else
      return null
  ).property('new_posts', 'posts_count')

  is_all_users_path: (path) ->
    return true if path is 'posts.all'
    return true if path is 'posts.popular'
    return true if path is 'posts.user'
    return true if path is 'posts.search'
    false

  actions:
    logout: ->
      clearTimeout(@timer)
      $.getJSON('user/logout').done (data) =>
        if data.status is 'ok'
          @set 'login_user', null
          @set 'login_admin', false
          @transitionToRoute 'posts.all' unless is_all_users_path(@get('currentPath'))
