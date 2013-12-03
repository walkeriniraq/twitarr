Twitarr.EntryReplyController = Twitarr.ObjectController.extend
  actions:
    make_post: ->
      text = @get 'text'
      return unless text.trim()

      Twitarr.Post.new(text.trim()).done (data) =>
        return alert(data.status) unless data.status is 'ok'
        @send('reload')
      @set 'text', ''

  set_replying_name: (->
    @set 'text', "@#{@get('from')} "
  ).observes('from')

  reply_post_type: (->
    @get('type') is 'post'
  ).property('type')
