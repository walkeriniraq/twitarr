Twitarr.EntryReplyController = Twitarr.ObjectController.extend
  set_replying_name: (->
    @set 'newPost', "@#{@get('from')} "
  ).observes('from')

