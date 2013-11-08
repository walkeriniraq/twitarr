Twitarr.EntryDetailsController = Twitarr.ObjectController.extend

  post_by_friend: (->
    _(@get('friends')).contains @get('from')
  ).property('friends', 'from')


  entry_class: (->
    switch @get('type')
      when 'announcement' then 'announcement-entry'
      when 'post' then 'post-entry'
  ).property('type')