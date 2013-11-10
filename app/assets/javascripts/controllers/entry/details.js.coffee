Twitarr.EntryDetailsController = Twitarr.ObjectController.extend

  post_by_friend: (->
    _(@get('friends')).contains @get('from')
  ).property('friends', 'from')


  entry_class: (->
    switch @get('type')
      when 'announcement' then 'announcement-entry'
      when 'post' then 'post-entry'
  ).property('type')

  can_delete: (->
    return false unless @get('logged_in')
    return true if @get('login_admin')
    @get('login_user') is @get('username')
  ).property('logged_in', 'login_user', 'login_admin')

  can_reply: (->
    @get('type') isnt 'announcement'
  ).property('type')

  can_like: (->
    @get('type') isnt 'announcement' and not @get('user_liked')
  ).property('user_liked', 'type')

