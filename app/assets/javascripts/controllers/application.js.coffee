Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  login_admin: false
  new_email: true
  friends: []
  logging_in: true

  init: ->
    $.getJSON('user/username').done (data) =>
      if data.status is 'ok'
        @login data.user, data.friends
      else
        @transitionToRoute 'announcements' if @get('currentPath') is 'posts.mine'
      @set 'logging_in', false

  login: (user, friends) ->
    @set 'login_user', user.username
    @set 'login_admin', user.is_admin
    @set 'friends', friends

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

  actions:
    logout: ->
      $.getJSON('user/logout').done (data) =>
        if data.status is 'ok'
          @set 'login_user', null
          @set 'login_admin', false
          @set 'friends', []
          @transitionToRoute 'announcements' if @get('currentPath') is 'posts.mine'

