app.controller 'headController', ["$scope", ($scope) ->

	defaultValue = "bootstrap.min.css"
	key = "themeBootstrapKaribou"
	#theme = $cookies.get key
	theme = localStorage[key]
	if theme
		$scope.link = theme
	else
		$scope.link = defaultValue

	nav = getNavigator()
	if nav.safari || nav.ie || nav.opera
		$scope.link = "lol.css"

	$scope.$on('changingThemeEvent', (event, data) ->
		event.defaultPrevented = true
		$scope.link = data.newTheme
		#$cookies.put key, data.newTheme
		localStorage[key] = data.newTheme
	)

	cacheName = {}
	$scope.$on("cacheNameChange", (event, data) ->
		cacheName = data
	)

	window.onbeforeunload = (e) ->
		e = e || window.event
		
		#$cookies.putObject "karibouCacheName", cacheName
		if cacheName && cacheName != undefined && cacheName != "undefined" && !isEmpty(cacheName)
			localStorage["karibouCacheName"] = JSON.stringify cacheName
		null
]	

isEmpty = (obj) ->
	if obj == null
		return true
	if obj.length > 0
		return false
	if obj.length == 0
		return false
	for key in obj
		if Object.prototype.hasOwnProperty.call(obj, key)
			return false
	return true

getNavigator = ->
	r = {}
	r.chrome = navigator.userAgent.indexOf('Chrome') > -1
	r.ie = navigator.userAgent.indexOf('MSIE') > -1
	r.firefox = navigator.userAgent.indexOf('Firefox') > -1
	r.safari = navigator.userAgent.indexOf("Safari") > -1
	r.opera = navigator.userAgent.toLowerCase().indexOf("op") > -1
	if r.chrome
		r.safari = false
	if r.opera
		r.chrome = false
	return r

app.factory 'preparedRequest', ["$http", ($http) ->

	return ->
		$http.defaults.headers.common['Authorization'] = 'Token ' + window.karibou.token
		return $http
]

app.factory 'cache', ['preparedRequest', "$rootScope", (pr, $rootScope) ->
	#cache = $cookies.getObject("karibouCacheName") || {}
	cache = localStorage["karibouCacheName"]
	console.log cache
	if cache
		cache = JSON.stringify cache
	else
		cache = {}
	cache_loading = {}
	return (id) ->
		#console.log id, cache, cache[id]
		if cache[id]
			return cache[id]
		else
			# Envoyer les requêtes ici
			# console.log 'Envoyer les requetes pour les noms'
			l = ""
			if cache_loading[id]
				return l
			cache_loading[id] = true
			http = pr()
			console.log id
			http.get(window.api_server + 'users/users/' + id + '/').
				success((d) ->
					console.log d
					cache[d.id] = d.username
					cache_loading[d.id] = undefined
					$rootScope.$broadcast("cacheNameChange", cache)
				)

			return l
]
