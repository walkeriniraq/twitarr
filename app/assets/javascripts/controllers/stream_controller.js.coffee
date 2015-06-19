#####################################################################################
# TODO: Move most individual stream posts into their own model/controller. Messy :( #
#####################################################################################
@Twitarr.controller 'StreamCtrl', ($scope, $http, $location) ->
  $scope.posts = []
  $scope.new_post_visible = false
  $scope.new_post_button_visible = false # TODO: Should be based on if user is logged in
  $scope.loading_posts = false
  firstPage = Math.ceil(new Date().valueOf() + 1000)
  nextPage = 0

  $scope.toggle_new_post = ->
    $scope.new_post_visible = !$scope.new_post_visible

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
      # this is so much messier than it should be, wtf happened???
      if false # TODO: if user logged in
        tweets[i].likeable = true
        if tweets[i].likes and tweets[i].likes.length > 0
          tweets[i].user_likes = (tweets[i].likes[0] == 'You')
          tweets[i].likeable = !tweets[i].user_likes
          tweets[i].unlikable = tweets[i].user_likes
      else
        [tweets[i].likeable, tweets[i].unlikeable] = false
        # end TODO
      tweets[i].likes = likes_string(tweets[i].likes)
      $scope.posts.push tweets[i]
      i++
    $scope.loading_posts = false
    #console.log "Posts loaded."

  getTweets = (page) ->
    $http.get("/stream/#{page}").success (data) ->
      nextPage = data.next_page
      addTweets(data.stream_posts);

  $scope.reloadTweets = ->
    $scope.posts = []
    $scope.loading_posts = true
    getTweets(Math.ceil(new Date().valueOf() + 1000))

  $scope.viewThread = (id) ->
    $location.path("/stream/tweet/#{id}")

  getTweets(firstPage)

  $(window).scroll ->
    # FUCKING BROWSERS
    # Each browser seems to treat all the elements used in this differently.
    # So, this is the only method that seems to work for all
    if @ie_browser or @ff_browser
      detected = document.documentElement.clientHeight + document.documentElement.scrollTop >= document.body.offsetHeight - 1000 and !$scope.loading_posts
    else
      detected = window.innerHeight + document.body.scrollTop >= document.body.offsetHeight - 1000 and !$scope.loading_posts
      
    if detected
      #console.log "Loading new posts..."
      $scope.loading_posts = true
      getTweets(nextPage)

@Twitarr.controller 'StreamPostCtrl', ['$scope', '$http', '$routeParams', "$location", ($scope, $http, $routeParams, $location) ->
  $scope.post = null
  $scope.parents = []
  $scope.children = []

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

  formatTweet = (data) ->
    tweet = data
    tweet.root = true
    tweet.likes = likes_string(data.likes)
    tweet.timestamp_ago = moment(data.timestamp)
    return tweet

  formatTweets = (data) ->
    tweets = []
    i = 0
    while i < data.length
      data[i].likes = likes_string(data[i].likes)
      data[i].timestamp_ago = moment(data[i].timestamp)
      tweets.push data[i]
      i++
    return tweets

  getTweet = (id) ->
    $http.get("/api/v2/stream/#{id}").success (data) ->
      $scope.post = formatTweet(data)
      $scope.children = formatTweets(data.children) if data.children != undefined
      $scope.parents = formatTweets(data.parents) if data.parents != undefined

  finishLoading = ->
    if $scope.post == null
      # Loop until useful.
      window.setTimeout(finishLoading,10)
    else
      $("#loading-overlay").fadeOut(50)
      $("#tweetContainer").fadeIn(80)

  $scope.viewThread = (id) ->
    $location.path("/stream/tweet/#{id}")

  $scope.refresh = ->
    $("#loading-overlay").show()
    $("#tweetContainer").hide()
    $scope.post = null
    $scope.parents = []
    $scope.children = []
    getTweet($routeParams.page)
    finishLoading()

  $scope.displayPhoto = (id) -> 
    $("#photo_modal #photo-holder img").attr("src", "/photo/full/#{id}")
    $("#photo_modal").show()

  $("#loading-overlay").fadeIn(50)
  getTweet($routeParams.page)
  finishLoading()
]