Twitarr.UserMeta = Ember.Object.extend
  username: null
  display_name: null
  email: null
  room_number: null
  number_of_tweets: null
  number_of_mentions: null
  # TODO: this is an interesting idea, but don't have time now
#  current_location: null
#  location_timestamp: null

Twitarr.User = Twitarr.UserMeta.extend
  recent_tweets: []

  objectize: (->
    @set('recent_tweets', Ember.A(Twitarr.StreamPost.create(tweet)) for tweet in @get('recent_tweets'))
  ).on('init')

Twitarr.User.reopenClass
  get: (username) ->
    $.getJSON("user/profile/#{username}").then (data) =>
      alert(data.status) unless data.status is 'ok'
      @create data.user
