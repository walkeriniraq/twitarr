@Twitarr.controller 'NavCtrl', ($scope) ->
	$scope.logged_in = false
	$scope.logged_in_admin = false
	$scope.user = ""
	$scope.display_name = ""
	$scope.alerts = false
	$scope.menu_toggle = ->
		$('#side-menu').animate { width: 'toggle' }, 100
		return