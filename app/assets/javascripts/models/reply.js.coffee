Twitarr.Reply = Ember.Object.extend
  username: null
  message: null
  timestamp: null

  pretty_name: (->
    @get('display_name') || "@#{@get('username')}"
  ).property('display_name', 'username')
