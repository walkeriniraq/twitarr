Twitarr.Post = Twitarr.BasePost.extend()

Twitarr.Post.reopenClass

  new: (text) ->
    @post('posts', text)

  search: (tag) ->
    @get_list("posts/search?term=#{encodeURIComponent tag}")

  popular: ->
    @get_list("posts/popular")

  all: (before_time = null) ->
    unless before_time
      @get_list("posts/all")
    else
      @get_list("posts/all?before=#{encodeURIComponent before_time}")

  user: (username, page = 0) ->
    @get_list("posts/list?username=#{encodeURIComponent username}&page=#{encodeURIComponent page}")

  mine: (params) ->
    @get_list("posts/list")

  favorite: (id) ->
    $.ajax(type: 'PUT', url: 'posts/favorite', data: { id: id }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  delete: (id) ->
    Twitarr.BasePost.delete('posts', id)
