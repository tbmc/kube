
if !window.karibou
	window.karibou = {}

app.controller 'allPageController', ['$scope', '$http', '$location', '$animate', "$rootScope",
($scope, $http, $location, $animate, $rootScope) ->
	$scope.isCollapsed = false
	$scope.isActive = (viewLocation) ->
		return false
		#console.log viewLocation, window.location.pathname
		#return viewLocation == window.location.pathname

	$scope.menus = menusAngular

	$scope.$on("$locationChangeStart", (event, data) ->
		activeMenuRefresh($scope.menus, $location.path())
	)

	$scope.isConnected = false

	$scope.login = ''
	$scope.password = ''

	allowedPages = [
		'/'
		'/theme'
		#"/files" # Uniquement pour le debug offline, à enlever pour la prod
	]

	$scope.isAllowedPage = ->
		url = $location.url()
		for p in allowedPages
			if p == url
				return true
		false
	
	$scope.previousConnection = false
	connect_at_startup = ->
		#cookie = $cookies.getObject 'karibouCookie'
		cookie = localStorage['karibouCookie']
		console.log cookie, typeof cookie
		if cookie and cookie != "undefined"
			cookie = JSON.parse cookie
			$scope.previousConnection = true
			$scope.isConnected = 1
			$http.defaults.headers.common['Authorization'] = 'Token ' + cookie.token
			$http.get(window.api_server + "okauth/checktoken/").#'chat/channels/').
			success((data) ->
				#console.log data
				if data
					finish_connection cookie.username, cookie.token
				else
					$scope.disconnect()
			).error((data) ->
				$scope.disconnect()
			)
		

			

	$scope.connect = (login, password) ->
		url = window.api_server + 'okauth/login/'

		$scope.isConnected = 1
		$scope.previousConnection = false

		$http.post(url, {
			'username': login
			'password': password
		}, {
			#withCredentials: true
			headers: {
				'Content-Type': 'application/json'
			}	
		}).success((data, status, headers, config) ->
			###$cookies.putObject 'karibouCookie', {
				username: data.username
				token: data.token
				id: data.id
			}###
			localStorage["karibouCookie"] = JSON.stringify {
				username: data.username
				token: data.token
				id: data.id
			}
			finish_connection(data.username, data.token)
			
		).error((response) ->
			console.log response
			$scope.isConnected = 3
		)

	finish_connection = (username, token) ->
		$scope.isConnected = 2
		$scope.username = username
		
		window.karibou.token = token
		
		#$rootScope.$broadcast "connectionToken", token
		

	$scope.retry_login = ->
		$scope.isConnected = false

	$scope.disconnect = ->
		if(!$scope.isConnected)
			return
		#$cookies.remove 'karibouCookie'
		localStorage["karibouCookie"] = undefined
		$scope.isConnected = false
		
		$scope.previousConnection = false
		$http.post(window.api_server + 'okauth/logout/')

	connect_at_startup()
]


activeMenuRefresh = (tab, path) ->
	r = false
	for t in tab
		if t.dropdown
			rr = activeMenuRefresh(t.dropdown, path)
			if rr
				t.active = true
				r = true
			else
				t.active = false
		else
			if t.path == path
				r = true
				t.active = true
			else
				t.active = false
	return r