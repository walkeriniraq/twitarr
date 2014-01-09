Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  login_admin: false
  new_email: false
  email_count: 0
  new_posts: false
  posts_count: 0

  init: ->
    $.ajax('user/username', dataType: 'json', cache: false).done (data) =>
      if data.status is 'ok'
        @login data.user

  login: (user) ->
    @set 'login_user', user.username
    @set 'login_admin', user.is_admin
    @tick()

  tick: ->
    $.ajax('user/update_status', dataType: 'json', cache: false).done (data) =>
      if data.status is 'ok'
        @set 'new_email', data.new_email > 0
        @set 'email_count', data.new_email
        @set 'new_posts', data.new_posts > 0
        @set 'posts_count', data.new_posts
        @timer = setTimeout (=> @tick()), 60000

  logged_in: (->
    @get('login_user')?
  ).property('login_user')

  display_new_email_link: (->
    if @get 'logged_in'
      on_seamail = @get('currentPath').indexOf('seamail') == 0
      return !on_seamail && @get 'new_email'
  ).property('logged_in', 'new_email', 'currentPath')

  email_count_display: (->
    if @get 'logged_in'
      count = @get('email_count')
      if count > 0
        return count
      else
        return null
  ).property('logged_in', 'email_count')

  posts_count_display: (->
    if @get 'logged_in'
      count = @get('posts_count')
      if count > 0
        return count
      else
        return null
  ).property('logged_in', 'posts_count')

  actions:
    create_post: ->
      @transitionToRoute 'create_post'
    logout: ->
      clearTimeout(@timer)
      $.getJSON('user/logout').done (data) =>
        if data.status is 'ok'
          @set 'login_user', null
          @set 'login_admin', false
          @transitionToRoute 'announcements' if @get('currentPath') is 'posts.mine'
