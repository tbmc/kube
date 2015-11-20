# Cherche dans un tableau si il contient un objet contenant les même propriétés que elements
# Si oui, la fonction retourne cet élément, sinon elle retourne false
aHasE = (array, elements) ->
	keys = Object.keys(elements)
	l = keys.length
	for a in array
		b = 0
		for key in keys
			if a[key] == elements[key]
				b++
		if b == l
			return a

	return false

# Retourne l'objet contenant "active"
activeTab = (tabs) ->
	for i in [0...tabs.length]
		if tabs[i].active
			return i
	return -1

###cacheChat = localStorage["cacheChat"]
if cacheChat
	cacheChat = JSON.parse cacheChat
else###
cacheChat = {
	convs: []
	users: []
	tabs: [
		{
			convId: 1
			title: 'general'
			active: true
			textModel: ''
			messages: []
			lastResponse: true
			scrollBottom: true
		}
	]
}

app.controller 'chatController', ['$scope',
'preparedRequest', '$window', 'cache', '$interval', "$rootScope",
($scope, pr, $window, cache, $interval, $rootScope) ->

	$scope.colorLine = (idx) ->
		if idx % 2 != 0
			return {'background-color': '#eee'}
		else
			return {'background-color': '#fff'}

	$scope.addDiscussion = (name) ->
		$scope.tabs.push {
			title: name
			content: name
		}

	# Permet de fermer une discussion lorsque l'on clique sur la croix
	$scope.closeDiscussion = (name) ->
		for idx in [0...$scope.tabs.length]
			tab = $scope.tabs[idx]
			if tab.title == name
				$scope.tabs.splice idx, 1
				break
		null

	# Ajoute une conversation au tableau des conversations.
	$scope.addConv = (id) ->
		a = aHasE($scope.tabs, { convId: id })
		if a
			a.active = true
			return
		a = aHasE($scope.convs, { id: id })
		$scope.tabs.push {
			convId: a.id
			title: a.name
			active: true
			textModel: ''
			messages: []
			lastResponse: true
		}

	$scope.showDateLine = (tab, index) ->
		if index <= 0
			return true
		t1 = tab[index - 1]
		t2 = tab[index]
		#console.log t1.dayOfMonth, t2.dayOfMonth, index, t1.dayOfMonth == t2.dayOfMonth

		return t1.dayOfMonth != t2.dayOfMonth

	# Envoi un message
	$scope.sendMessage = (convId) ->
		a = aHasE($scope.tabs, {convId: convId})
		if a.textModel.length == 0
			return
		content = a.textModel
		a.textModel = ''
		http = pr()
		http.post(window.api_server + 'chat/posts/', {
			content: content
			channel: convId
		}).success((data) ->
			refreshAllDiscussions()
		)

	###
	# Tableau contenant toutes les conversations en cours
	$scope.convs = []
	# Tableau contenant tous les utilisateurs connectés
	$scope.users = []
	# Tableau contenant toutes les discussions ouvertes
	$scope.tabs = [
		{
			convId: 1
			title: 'general'
			active: true
			textModel: ''
			messages: []
			lastResponse: true
			scrollBottom: true
		}
	]
	###
	
	$scope.convs = cacheChat.convs
	$scope.users = cacheChat.users
	$scope.tabs = cacheChat.tabs

	# Ajout de la fonction permettant d'avoir un cache de pseudo en fonction du ID, dans le scope
	$scope.username = cache

	promise = {}
	promise.rd = $interval(() ->
		refreshAllDiscussions()
	, 1000)
		
	promise.rf = $interval(->
		$scope.refresh()
		# Save chat in cache
		#if cacheChat
		#	localStorage["cacheChat"] = JSON.stringify cacheChat
	, 5000)
	
	$scope.$on "$destroy", ->
		if promise
			$interval.cancel promise.rd
			$interval.cancel promise.rf

	$scope.getPrevious = (convId) ->
		a = aHasE $scope.tabs, {
			convId: convId
		}
		if !a.lastResponse
			# Préviens qu'on veut rafraichir
			a.needRefresh = true
			return
		a.needRefresh = false
		if !a or !(a.previous)
			return
		a.lastResponse = false
		http = pr()
		http.get(a.previous).
		success((data) ->
			a.previous = data.previous
			appendDataOnTab a, data.results, true
			a.lastResponse = true
		)

		#console.log a.previous


	# Met à jour tous les onglets de discussion ouverts
	refreshAllDiscussions = () ->
		elements = document.getElementsByClassName "scrollMessages"
		for idx in [0...$scope.tabs.length]
			tab = $scope.tabs[idx]
			refreshTab(tab, elements[idx])

	# Met à jour un onglet de discussion (ouvert, enfin normalement)
	refreshTab = (tab, element) ->
		if !tab.lastResponse
			return
		tab.lastResponse = false
		http = pr()
		last = 0
		addInUrl = "&page=last"
		if tab.messages.length > 0
			last = tab.messages[tab.messages.length - 1].id
			addInUrl = "&afterid=" + last
		http.get(window.api_server + "chat/posts/?channel=" + tab.convId + addInUrl + "&items=25").
			success((data) ->
				# Permet de savoir si on doit être toujours en bas ou non
				if element
					scrollPos = element.scrollTop
					maxScrollPos = element.scrollHeight - element.clientHeight
					tab.scrollBottom = (scrollPos == maxScrollPos)
				# Ajout des données
				appendDataOnTab(tab, data.results)
				if data.previous
					tab.previous = data.previous
			)
		return

	# Ajout des données dans une discussion en cours
	appendDataOnTab = (tab, data, debut = false) ->
		if debut
			data = data.reverse()
		for d in data
			dom = new Date d.date
			tatab = {
				id: d.id
				author: d.author
				username: cache(d.author)
				date: d.date
				dayOfMonth: dom.getDate() + "/" + dom.getMonth() + "/" + dom.getFullYear()
				content: d.content
			}
			if debut
				tab.messages.splice(0, 0, tatab)
			else
				tab.messages.push tatab
		tab.lastResponse = true
		# Si il était en train de charger pendant que l'utilisateur a demandé, il faut lancer le rafraichissement
		if tab.needRefresh
			$scope.getPrevious()

	# Met à jour la liste des conversations
	$scope.refresh = () ->
		http = pr()
		http.get(window.api_server + 'chat/channels/').
		success((data) ->
			#console.log data
			if !$scope.convs
				$scope.convs = []
			data.forEach((d) ->
				if aHasE $scope.convs, {
					id: d.id
					name: d.name
				}
					return

				$scope.convs.push {
					id: d.id
					name: d.name
					users: []
					public: d.public
				}
				http.get(window.api_server + 'chat/channels/' + d.id + '/userperms/').
				success((data2) ->
					tab = aHasE($scope.convs, {id: d.id})
					tab.users = []
					for d2 in data2
						tab.users.push d2.user
					#console.log tab.users
				)
			)
		)

	# Permet de gérer les redimensionnement de la fenêtre
	resizeWindow = (w, h) ->
		el = document.getElementById('userListId')
		if w >= 992 && el
			top = el.getBoundingClientRect().top
			$scope.containerHeight = {
				height: (h - top - 30) + 'px'
			}
			bottom = 100
			$scope.bottomHeight = {
				height: (bottom) + 'px'
			}
			$scope.innerHeight = {
				height: (h - top - 102 - bottom) + 'px'
			}
			$scope.innerHeightConvs = {
				height: (h - top - 140) + 'px'
			}
		else
			$scope.containerHeight = false
			$scope.innerHeight = false
			$scope.bottomHeight = false
			$scope.innerHeightConvs = false

		$scope.$apply()

	initializeWindowSize = ->
		$scope.windowHeight = $window.innerHeight
		$scope.windowWidth = $window.innerWidth

	# Ajout de l'event
	angular.element($window).bind 'resize', ->
		initializeWindowSize()
		resizeWindow $scope.windowWidth, $scope.windowHeight
		$scope.$apply()

	# Appel une première fois à la fonction de redimensionnement
	angular.element(document).ready ->
		resizeWindow $window.innerWidth, $window.innerHeight
	
]