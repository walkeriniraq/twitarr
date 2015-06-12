@Twitarr.controller 'StreamCtrl', ($scope, $http) ->
  $scope.posts = []
  page = Math.ceil(new Date().valueOf() + 1000)

  likes_string = (likes) ->
    return '' unless likes and likes.length > 0
    if likes.length == 1
      if likes[0] == 'You'
        return 'You like this.'
      if likes[0].indexOf 'seamonkeys' > -1
        return "#{likes[0]} like this."
      else
        return "#{likes[0]} likes this."
    last = likes.pop()
    likes.join(', ') + " and #{last} like this."

  addTweets = (tweets) ->
    i = 0
    while i < tweets.length
      tweets[i].timestamp_ago = moment(tweets[i].timestamp)
      # TODO: if user logged in
      # this is so much messier than it should be, wtf happened???
      tweets[i].likeable = true
      if tweets[i].likes and tweets[i].likes.length > 0
        tweets[i].user_likes = (tweets[i].likes[0] == 'You')
        tweets[i].likeable = !tweets[i].user_likes
        tweets[i].unlikable = tweets[i].user_likes
      # else
      #[tweets[i].likeable, tweets[i].unlikeable] = false
      # end TODO
      tweets[i].likes = likes_string(tweets[i].likes)
      $scope.posts.push tweets[i]
      i++

  $http.get('/stream/' + page).success (data) ->
    addTweets(data.stream_posts);
    return
  return