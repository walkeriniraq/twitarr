class Post
  constructor: (post) ->
    @message = ko.observable(post.message)
    @username = ko.observable(post.username)
    @post_time = ko.observable(post.post_time)

class User
  constructor: ->
    @username = ko.observable(null)
    @is_admin = ko.observable(false)

    @update = (user) ->
      @username(user.username)
      @is_admin(user.is_admin)

    @clear = ->
      @username(null)
      @is_admin(false)

class Twitarr
  constructor: ->
    @user = new User()
    @announcements = ko.observableArray()
    @posts = ko.observableArray()
    @logged_in = ko.computed =>
      @user.username() != null
    @screen = ko.observable('announcements')
    @announcements_screen = ko.computed =>
      @screen() == 'announcements'
    @popular_screen = ko.computed =>
      @screen() == 'popular'
    @all_screen = ko.computed =>
      @screen() == 'all'
    @my_stuff_screen = ko.computed =>
      @screen() == 'my-stuff'
    @profile_screen = ko.computed =>
      @screen() == 'profile'
    @login_screen = ko.computed =>
      @screen() == 'login'

    @logout = ->
      $.getJSON 'app/user/logout', (data) =>
        if data.status is 'ok'
          @user.clear()

    @login = (user) ->
      @user.update(user)

    @add_announcements = (list) =>
      @announcements.push new Post(announcement) for announcement in list

    @add_posts = (list) =>
      @posts.push new Post(post) for post in list

    @set_panel = (data, event) =>
      @screen($(event.target).data('section'))

window.twitarr = new Twitarr()

$ ->
  ko.applyBindings window.twitarr
  $('#login-submit').click ->
    $.post 'app/user/login', { username: $('#login-username').val(), password: $('#login-password').val() }, (data) ->
      if data.status is 'ok'
        login(data.user)
        window.twitarr.screen('announcements')

  $('#post-submit').click ->
    $.post 'app/posts/submit', { message: $('#post-text').val() }, (data) ->
      if data.status is 'ok'
        load_posts()

  $('#post-announcement-submit').click ->
    $.post 'app/announcements/submit', { message: $('#post-announcement-text').val() }, (data) ->
      if data.status is 'ok'
        load_announcements()

  $.getJSON 'app/user/username', (data) ->
    if data.status is 'ok'
      login(data.user)

  load_announcements()
  load_posts()

load_announcements = ->
  $.getJSON 'app/announcements/list', (data) ->
    window.twitarr.announcements.removeAll()
    window.twitarr.add_announcements(data.list)

load_posts = () ->
  $.getJSON 'app/posts/list', (data) ->
    window.twitarr.posts.removeAll()
    window.twitarr.add_posts(data.list)

login = (user) ->
  window.twitarr.login(user)

logout = ->
  window.twitarr.logout()
