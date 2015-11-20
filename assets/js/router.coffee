
app.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
	rp = $routeProvider

	rp.when '/', {
		templateUrl: 'mainView'
		controller: 'homePage'
		controllerAs: 'main'
	}


	rp.when '/files', {
		templateUrl: 'filesView'
		controller: 'filesController'
		controllerAs: 'filesController'
	}
	rp.when '/files/:filename', {
		templateUrl: 'filesView'
		controller: 'filesController'
		controllerAs: 'filesController'
	}

	rp.when '/chat', {
		templateUrl: 'chatView'
		controller: 'chatController'
		controllerAs: 'chatController'
	}

	rp.when '/theme', {
		templateUrl: 'themeView'
		controller: 'themeController'
		controllerAs: 'themeController'
	}

	rp.when '/account', {
		templateUrl: "accountView"
		controller: "accountController"
		controllerAs: "accountController"
	}
	rp.when "/account/:id", {
		templateUrl: "accountView"
		controller: "accountController"
		controllerAs: "accountController"
	}

	rp.otherwise {
		redirectTo: '/'
	}

	$locationProvider.html5Mode {
		enabled: true
		requireBase: false
	}
]
