app.controller 'homePage', ['$scope', '$http', ($scope, $http) ->
	$scope.test = () ->
		window.karibou.prepare $http
		$http.get(window.api_server + 'posts/', {
			
		}, {
			headers: {
				'Content-Type': 'application/json'
			}
		}).success((r) ->
			console.log r
		).error((r) ->
			console.log r
		)

]

