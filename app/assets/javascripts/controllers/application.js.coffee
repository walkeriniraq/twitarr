Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  is_admin: false
  friends: []

  init: ->
    $.getJSON('user/username').done (data) =>
      if data.status is 'ok'
        @login data.user
#      else
        #TODO: only transition if the current route is "mine"
#        @transitionToRoute 'announcements'

  logout: ->
    $.getJSON('user/logout').done (data) =>
      if data.status is 'ok'
        @set 'login_user', null
        @set 'is_admin', false
        @transitionToRoute 'announcements'

  login: (user) ->
    @set 'login_user', user.username
    @set 'is_admin', user.is_admin
    @set 'friends', user.friends

  logged_in: (->
    @get('login_user')?
  ).property('login_user')

