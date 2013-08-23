Twitarr.BasePostChildController = Twitarr.ObjectController.extend
  delete: (id) ->
    Twitarr.Post.delete(id).done (data) =>
      return alert(data.status) unless data.status is 'ok'
      posts = _(@get('posts')).reject (x) -> x.post_id is id
      @set 'posts', posts

  make_post: ->
    text = @get 'newPost'
    return unless text.trim()

    Twitarr.Post.new(text).done (data) =>
      return alert(data.status) unless data.status is 'ok'
      @reload()
    @set 'newPost', ''

