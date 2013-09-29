Twitarr.Post = Twitarr.BasePost.extend()

Twitarr.Post.reopenClass

  new: (text) ->
    @post('posts', text)

  search: (tag) ->
    @get_list("posts/search?term=#{encodeURIComponent tag}")

  popular: ->
    @get_list("posts/popular")

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
