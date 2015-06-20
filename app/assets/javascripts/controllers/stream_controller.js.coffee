likes_string = (likes) ->
  return '' unless likes and likes.length > 0
  if likes.length == 1
    if likes[0] == 'You'
      return 'You like this.'
    # I have no idea wtf happened here, it kept using the standard "like" this based on the indexOf
    if likes.length == 1
      return "#{likes[0]} likes this"
    if likes[0].indexOf 'seamonkeys' > -1
      return "#{likes[0]} like this."
    else
      return "#{likes[0]} likes this."
  last = likes.pop()
  likes.join(', ') + " and #{last} like this."

@Twitarr.controller 'NewPostCtrl', ($scope, $http, $route, UserService) ->
  $scope.submitting = false
  $scope.newPost = 
    'text': ''
    'upload': undefined
  $scope.errors = []
  $scope.submit = () ->
    # TODO: Image uploading
    $scope.submitting = true
    $scope.errors = []
    $http(
      method: 'POST'
      url: "stream"
      params:
        text: $scope.newPost.text
      cache: false
      timeout: 5000
      headers: Accept: 'application/json').success((data, status, headers, config) ->
        $scope.submitting = false
        $route.reload()
      ).error (data, status, headers, config) ->
        $scope.errors = data.errors
        return
    

#####################################################################################
# TODO: Move most individual stream posts into their own model/controller. Messy :( #
# Okay. Apparently this is impossible to pass objects between controllers well      #
# which makes it much harder to just have a controller for indiviudal posts...      #
#####################################################################################
@Twitarr.controller 'StreamCtrl', ($scope, $http, $location, UserService) ->
  $scope.user = UserService.get()
  $scope.posts = []
  $scope.new_post_visible = false
  $scope.loading_posts = false
  firstPage = Math.ceil(new Date().valueOf() + 1000)
  nextPage = 0

  $scope.toggle_new_post = ->
    $scope.new_post_visible = !$scope.new_post_visible

  addTweets = (tweets) ->
    i = 0
    while i < tweets.length
      tweets[i].timestamp_ago = moment(tweets[i].timestamp)
      # this is so much messier than it should be, wtf happened???
      if $scope.user.loggedIn
        tweets[i].owned = (tweets[i].author == $scope.user.username)
        if tweets[i].likes and tweets[i].likes.length > 0
          tweets[i].user_likes = (tweets[i].likes[0] == 'You')
      tweets[i].likes = likes_string(tweets[i].likes)
      $scope.posts.push tweets[i]
      i++
    $scope.loading_posts = false
    @tweets = $scope.posts
    #console.log "Posts loaded."

  getTweets = (page) ->
    $http.get("/stream/#{page}").success (data) ->
      nextPage = data.next_page
      addTweets(data.stream_posts);

  $scope.refresh = ->
    $scope.posts = []
    $scope.loading_posts = true
    getTweets(Math.ceil(new Date().valueOf() + 1000))

  $scope.viewThread = (id) ->
    $location.path("/stream/tweet/#{id}")

  $scope.like = (post) ->
    $http(
      method: 'GET'
      url: "tweet/like/#{post.id}"
      params:
        key: $scope.user.key
      cache: false
      timeout: 5000
      headers: Accept: 'application/json').success((data, status, headers, config) ->
        post.likes = likes_string data.likes
        post.user_likes = !post.user_likes
      )
    
    return

  $scope.unlike = (post) ->
    $http(
      method: 'GET'
      url: "tweet/unlike/#{post.id}"
      params:
        key: $scope.user.key
      cache: false
      timeout: 5000
      headers: Accept: 'application/json').success((data, status, headers, config) ->
        post.likes = likes_string data.likes
        post.user_likes = !post.user_likes
      )
    return

  $scope.delete = (post) ->
    $http(
      method: 'GET'
      url: "tweet/destroy/#{post.id}"
      params:
        key: $scope.user.key
      cache: false
      timeout: 5000
      headers: Accept: 'application/json').success((data, status, headers, config) ->
        $scope.posts.splice $scope.posts.indexOf(post), 1
      )
    return

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

@Twitarr.controller 'StreamViewCtrl', ($scope, $http, $routeParams, $location) ->
  $scope.post = null
  $scope.parents = []
  $scope.children = []

  formatTweet = (data) ->
    tweet = data
    tweet.root = true
    if $scope.user.loggedIn
        tweet.owned = (tweet.author == $scope.user.username)
        if tweet.likes and tweet.likes.length > 0
          tweet.user_likes = (tweet.likes[0] == 'You')
    tweet.likes = likes_string(data.likes)
    tweet.timestamp_ago = moment(data.timestamp)
    return tweet

  formatTweets = (data) ->
    tweets = []
    i = 0
    while i < data.length
      tweets.push formatTweet(data[i])
      i++
    return tweets

  getTweet = (id) ->
    $http.get("/api/v2/stream/#{id}").success (data) ->
      $scope.post = formatTweet data
      $scope.children = formatTweets(data.children) if data.children != undefined
      $scope.parents = formatTweets(data.parents) if data.parents != undefined

  finishLoading = ->
    if $scope.post == null
      # Loop until useful.
      window.setTimeout(finishLoading,10)
    else
      $("#loading-overlay").fadeOut(50)
      $("#tweetContainer").fadeIn(80)
      #console.log $scope.post

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

  $scope.like = (post) ->
    $http(
      method: 'GET'
      url: "tweet/like/#{post.id}"
      params:
        key: $scope.user.key
      cache: false
      timeout: 5000
      headers: Accept: 'application/json').success((data, status, headers, config) ->
        post.likes = likes_string data.likes
        post.user_likes = !post.user_likes
      )
    
    return

  $scope.unlike = (post) ->
    $http(
      method: 'GET'
      url: "tweet/unlike/#{post.id}"
      params:
        key: $scope.user.key
      cache: false
      timeout: 5000
      headers: Accept: 'application/json').success((data, status, headers, config) ->
        post.likes = likes_string data.likes
        post.user_likes = !post.user_likes
      )
    return

  $scope.delete = (post) ->
    $http(
      method: 'GET'
      url: "tweet/destroy/#{post.id}"
      params:
        key: $scope.user.key
      cache: false
      timeout: 5000
      headers: Accept: 'application/json').success((data, status, headers, config) ->
        $location.path("/stream")
      )
    return

  $("#loading-overlay").fadeIn(50)
  getTweet($routeParams.page)
  finishLoading()