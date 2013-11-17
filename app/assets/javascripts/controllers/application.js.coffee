Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  login_admin: false
  new_email: false
  friends: []
  logging_in: true
  email_count: 0

  init: ->
    $.getJSON('user/username').done (data) =>
      if data.status is 'ok'
        @login data.user, data.friends, data.new_email
      else
        @transitionToRoute 'announcements' if @get('currentPath') is 'posts.mine'
      @set 'logging_in', false

  login: (user, friends, new_email) ->
    @set 'login_user', user.username
    @set 'login_admin', user.is_admin
    @set 'friends', friends
    @set 'new_email', new_email > 0
    @set 'email_count', new_email

  logged_in: (->
    @get('login_user')?
  ).property('login_user')

  hide_login_link: (->
    @get('currentPath') is 'login' or @get('logged_in') or @get('logging_in')
  ).property('logged_in', 'logging_in', 'currentPath')

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

  actions:
    logout: ->
      $.getJSON('user/logout').done (data) =>
        if data.status is 'ok'
          @set 'login_user', null
          @set 'login_admin', false
          @set 'friends', []
          @transitionToRoute 'announcements' if @get('currentPath') is 'posts.mine'

