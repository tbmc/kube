
fileRoute = "share/files/"
directoryRoute = "share/directories/"

app.controller 'filesController', ['$scope', "preparedRequest",
'$window', '$routeParams', "$uibModal", "fileUpload", "directoryCache",
($scope, pr, $window, $routeParams, $uibModal, fileUpload, directoryCache) ->
	
	# Permet de gérer l'affichage des fichiers

	#console.log $routeParams.filename, $routeParams.path
	

	$scope.path = []
	$scope.folders = []
	$scope.files = []
	path_folders = [1]
	$scope.loading = 0

	$scope.back = ->
		if path_folders.length <= 1
			n = 1
		else
			n = path_folders.pop()
		$scope.loadDirectory(n, true)

	$scope.uploadFile = ->
		uploadUrl = window.api_server + fileRoute
		fu = $scope.fileToUpload
		console.log("File : " + fu)
		fileUpload.uploadFileToUrl(fu, uploadUrl, "root", 1)

	$scope.loadDirectory = (dir_id, notAdd) ->
		$scope.loading = 3
		loadPath(dir_id, notAdd)
		loadDirectory(dir_id)
		loadFiles(dir_id)

	$scope.cache = directoryCache
	loadPath = (dir_id, notAdd) ->
		if !notAdd
			path_folders.push(dir_id)
		http = pr()
		http.get(window.api_server + directoryRoute + dir_id + "/").
			success((data) ->
				$scope.path = data.path_ids
				$scope.loading-- 
			)

	loadDirectory = (dir_id) ->
		$scope.folders = []
		http = pr()
		http.get(window.api_server + directoryRoute + "?parent=" + dir_id).
			success( (data) ->
				$scope.folders = toPrintArray(data)
				$scope.loading-- 
			)
	loadFiles = (dir_id) ->
		$scope.files = []
		http = pr()
		http.get(window.api_server + fileRoute + "?parent=" + dir_id).
			success( (data) ->
				$scope.files = toPrintArray(data)
				$scope.loading-- 
			)

	$scope.printFile = (id, url) ->
		http = pr()
		http.get(url).
		success((data) ->
			type = "text/html"
			console.log(escape(data))
			#angular.element("#iframeContent").attr("src",
			#	"data:" + type + ";charset=utf8" + escape(data))
			e = document.getElementById("iframeContent")
			e.setAttribute("src", "data:" + type + ";charset=utf8," + textToHtml(data))
			#resizeIframe(e)
		)

	$scope.loadDirectory(1)


	# Permet de gérer la partie upload de fichiers
	$scope.uploadLoading = false
	$scope.openUploadPopup = ->
		up = $uibModal.open({
			animation: true
			templateUrl: "uploadFilePopup.html"
			controller: "uploadControllerPopupController"
			size: "lg"
			backdrop: "static"
		})

	resizeWindow = ->
		w = $window.innerWidth
		h = $window.innerHeight
		el = document.getElementById("iframeContent")
		if w >= 992 && el
			top = el.getBoundingClientRect().top
			$scope.containerFrameHeight = {
				height: (h - top - 50) + "px"
			}
		refreshAngular($scope)

	angular.element($window).bind("resize", ->
		resizeWindow()
	)
	angular.element(document).ready(->
		resizeWindow()
	)
]


textToHtml = (text) ->
	debut = "<html><head></head><body><pre>"
	fin = "</pre></body></html>"
	return debut + escape(text) + fin

toPrintArray = (source) ->
	out = []
	for a in source
		out.push(toPrint(a))
	return out

getOnlyFromParent = (array, parent) ->
	out = {}
	for key, a of array
		if a.parent == parent
			out[key] = a
	return out

toPrint = (file) ->
	out = {
		name: file.name
		url: file.file
		parent: file.parent
		id: file.id
	}
	return out



app.controller("uploadControllerPopupController", ["$scope", "$uibModalInstance", "fileUpload", 
($scope, $uibModalInstance, fileUpload) ->
	$scope.close = ->
		$uibModalInstance.dismiss("cancel")


])

app.controller "ModalUploadFileController", ["$scope", "$uibModalInstance", "FileUploader", "$window",
($scope, $uibModalInstance, FileUploader, $window) ->

	uploader = $scope.uploader = new FileUploader {
		url: window.api_server + "share/files/"
	}

	$scope.close = ->
		$uibModalInstance.dismiss "cancel"

	angular.element($window).bind 'resize', ->
		resize()
	resize = ->
		#console.log $window.innerHeight
		$scope.dropStyle = {
			height: ($window.innerHeight / 3) + "px"
		}
		if !$scope.$$phase
			$scope.$apply()
	resize()
]