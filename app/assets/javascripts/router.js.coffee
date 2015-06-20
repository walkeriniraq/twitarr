@Twitarr.config ['$routeProvider',($routeProvider) ->
  $routeProvider
    .when('/stream',
      templateUrl: '/stream/stream.html',
      controller: 'StreamCtrl')
    .when('/stream/tweet/:page',
      templateUrl: '/stream/view.html',
      controller: 'StreamViewCtrl')
   	.when('/help',
   	  templateUrl: '/misc/help.html')
    .otherwise redirectTo: '/stream'
  return
]