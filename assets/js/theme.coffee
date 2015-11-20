app.controller 'themeController', ['$scope', '$rootScope',
($scope, $rootScope) ->
	
	#cookie = $cookies.get "themeBootstrapKaribou"
	cookie = localStorage["themeBootstrapKaribou"]
	if cookie
		$scope.selectedTheme = cookie
	else
		$scope.selectedTheme = "bootstrap.min.css"
	$scope.themesList = window.themesList

	$scope.themef = (theme) ->
		$rootScope.$broadcast('changingThemeEvent', {
			newTheme: theme
		})
		$scope.selectedTheme = theme
]