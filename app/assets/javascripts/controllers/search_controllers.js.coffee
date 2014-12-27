Twitarr.SearchResultsController = Twitarr.Controller.extend
  error: ''

Twitarr.SearchUserResultController = Twitarr.ObjectController.extend
  profile_pic: (->
    "/api/v2/user/photo/#{@get('username')}"
  ).property('username')
