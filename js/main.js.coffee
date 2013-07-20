class Post
  constructor: (post) ->
    @message = ko.observable post.message
    @username = ko.observable post.username
    @post_time = ko.observable post.post_time

class User
  constructor: ->
    @username = ko.observable null
    @is_admin = ko.observable false

  update: (user) ->
    @username user.username
    @is_admin user.is_admin

  clear: ->
    @username null
    @is_admin false

class Twitarr
  constructor: ->
    @user = new User()
    @announcements = ko.observableArray()
    @posts = ko.observableArray()
    @user_posts = ko.observableArray()
    @logged_in = ko.computed =>
      @user.username() != null
    @screen = ko.observable 'announcements'

  logout: ->
    $.getJSON 'user/logout', (data) =>
      if data.status is 'ok'
        @user.clear()

  login: (user) ->
    @user.update user
    @load_user_stuff() if @logged_in()

  set_panel: (data, event) ->
    @screen $(event.target).data 'section'

  load_announcements: ->
    $.getJSON 'announcements/list', (data) =>
      @announcements.removeAll()
      @announcements.push new Post(announcement) for announcement in data.list

  load_posts: ->
    $.getJSON 'posts/list', (data) =>
      @posts.removeAll()
      @posts.push new Post(post) for post in data.list

  load_user_stuff: ->
    $.getJSON 'posts/mine', (data) =>
      @user_posts.removeAll()
      @user_posts.push new Post(post) for post in data.list

  initialize: ->
    @load_announcements()
    @load_posts()

window.twitarr = new Twitarr()

$ ->
  ko.applyBindings twitarr
  $('#login-submit').click ->
    $.post 'user/login', { username: $('#login-username').val(), password: $('#login-password').val() }, (data) ->
      if data.status is 'ok'
        twitarr.login data.user
        twitarr.screen 'announcements'
      else
        alert data.status
    false

  $('#new-user-submit').click ->
    $.post 'user/new', {
      username: $('#new-username').val()
      email: $('#new-email').val()
      password: $('#new-password').val()
      password2: $('#new-password2').val()
    }, (data) ->
      if data.status is 'ok'
        alert 'Your account request is recieved and you will be notified when your account is activated.'
        twitarr.screen 'announcements'
      else
        alert data.status
    false

  $('#post-submit').click ->
    $.post 'posts/submit', { message: $('#post-text').val() }, (data) ->
      if data.status is 'ok'
        twitarr.load_posts()
      else
        alert data.status

  $('#post-announcement-submit').click ->
    $.post 'announcements/submit', { message: $('#post-announcement-text').val() }, (data) ->
      if data.status is 'ok'
        twitarr.load_announcements()
      else
        alert data.status

  $.getJSON 'user/username', (data) ->
    if data.status is 'ok'
      twitarr.login data.user

  twitarr.initialize()
