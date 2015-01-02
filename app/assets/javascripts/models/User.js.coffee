Twitarr.UserMeta = Ember.Object.extend
  username: null
  display_name: null
  public_email: null
  room_number: null
  # TODO: this is an interesting idea, but don't have time now
#  current_location: null
#  location_timestamp: null

Twitarr.User = Twitarr.UserMeta.extend
  tweets: []
  forums: []