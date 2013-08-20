Twitarr.Message = Ember.Object.extend
  process_message: (->
    msg = ''
    msg += @process_part(part) for part in @get('message').split /([@#]\w+)/
    msg
  ).property 'message'

  process_part: (part) ->
    switch part[0]
      when '@'
        "<a href='#/posts/user/#{part.substring 1}'>#{part}</a>"
      when '#'
        "<a href='#/posts/search/#{part.substring 1}'>#{part}</a>"
      else part

Twitarr.Message.reopenClass
  list: (type) ->
    @get_list "#{type}/list"

  post: (type, text) ->
    $.post("#{type}/submit", { message: text }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  delete: (type, id) ->
    $.post("#{type}/delete", { id: id }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  get_list: (url) ->
    $.getJSON(url).then (data) =>
      links = Ember.A()
      links.pushObject(@create(post)) for post in data.list
      { status: data.status, posts: links }

Twitarr.Post = Twitarr.Message.extend()

Twitarr.Post.reopenClass

  new: (text) ->
    @post('posts', text)

  search: (tag) ->
    @get_list("posts/search?term=#{encodeURIComponent tag}")

  popular: (page = 0) ->
    @get_list("posts/popular?page=#{encodeURIComponent page}")

  user: (username, page = 0) ->
    @get_list("posts/list?username=#{encodeURIComponent username}&page=#{encodeURIComponent page}")

  mine: (params) ->
    @get_list("posts/list")

  favorite: (id) ->
    $.ajax(type: 'PUT', url: 'posts/favorite', data: { id: id }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  delete: (id) ->
    Twitarr.Message.delete('posts', id)
