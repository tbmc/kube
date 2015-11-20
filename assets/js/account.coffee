app.controller 'accountController',
["$scope", "preparedRequest", "$routeParams", "cache", "$interval"
($scope, pr, $routeParams, cache, $interval) ->

	getId = ->
		cookie = localStorage["karibouCookie"]
		#cookie = $cookies.getObject "karibouCookie"

		if cookie
			cookie = JSON.parse cookie
			return cookie.id
		return null

	pseudo = null
	pseudoSentence = "Compte de "

	id = Number $routeParams.id
	if !id
		id = getId()
		$scope.accountTitle = "Votre compte"
	else
		pseudo = cache(id)
		$scope.accountTitle = pseudoSentence + pseudo

	http = pr()

	http.get(window.api_server + "users/users/" + id + "/").
	success((data) ->
		#console.log data
		$scope.tab = []
		for t in dataTab
			$scope.tab.push {
				title: t.title
				data: data[t.name]
				type: t.type
			}
	)

	promisePseudo = $interval(->
		if pseudo && pseudo.length < 1
			pseudo = cache(id)
			$scope.accountTitle = pseudoSentence + pseudo
		else
			$interval.cancel promisePseudo
	, 3000)

	dataTab = [
		{
			name: "username"
			title: "Pseudo"
			type: "text"
		}
		{
			name: "first_name"
			title: "Prénom"
			type: "text"
		}
		{
			name: "last_name"
			title: "Nom de famille"
			type: "text"
		}
		{
			name: "email"
			title: "Adresse mail"
			type: "email"
		}

	]


]