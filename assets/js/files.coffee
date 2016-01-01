
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
	actual_folder = 1
	$scope.loading = 0
	$scope.pathToSelectedFile = {
		url: ""
		path_ids: []
		name: ""
	}
		

	$scope.back = ->
		if path_folders.length <= 0
			return
		n = path_folders.pop()
		if actual_folder == n
			n = path_folders.pop()
		if !n
			n = 1
		$scope.loadDirectory(n, true)

	$scope.loadDirectory = (dir_id, notAdd) ->
		$scope.loading += 3
		loadPath(dir_id, notAdd)
		loadDirectory(dir_id)
		loadFiles(dir_id)

	$scope.cache = directoryCache
	loadPath = (dir_id, notAdd) ->
		if !notAdd
			path_folders.push(dir_id)
		actual_folder = dir_id
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

	$scope.printFile = (id, url, name, path_ids) ->
		$scope.loading++
		$scope.pathToSelectedFile = {
			url: url
			path_ids: path_ids
			name: name
		}
		http = pr()
		http.get(url).
		success((data) ->
			type = "text/plain"
			#angular.element("#iframeContent").attr("src",
			#	"data:" + type + ";charset=utf8" + escape(data))
			e = document.getElementById("iframeContent")
			e.setAttribute("src", "data:" + type + ";charset=iso-8859-15," + escape(data))
			#resizeIframe(e)
			$scope.loading--
		)
		refreshAngular()

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
				height: (h - top - 100) + "px"
			}
		else if el
			$scope.containerFrameHeight = {
				"min-height": "500px"
			}
		refreshAngular($scope)

	angular.element($window).bind("resize", ->
		resizeWindow()
	)
	angular.element(document).ready(->
		resizeWindow()
	)
	$scope.download = (url, name) ->
		#console.log(url)
		#window.location.href = url
		xhr = new XMLHttpRequest()
		xhr.onreadystatechange = ->
			if this.readyState == 4 and this.status == 200
				#console.log(this.response, typeof this.response)
				saveAs(this.response, name, true)
		xhr.open("GET", url)
		xhr.responseType = "blob"
		xhr.send()
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
		path_ids: file.path_ids
	}
	return out



app.controller("uploadControllerPopupController", ["$scope", "$uibModalInstance", "fileUpload", 
($scope, $uibModalInstance, fileUpload) ->
	$scope.close = ->
		$uibModalInstance.dismiss("cancel")

	$scope.uploadFile = ->
		uploadUrl = window.api_server + fileRoute
		fu = $scope.fileToUpload
		console.log("File : " + fu)
		fileUpload.uploadFileToUrl(fu, uploadUrl, fu.name, 1)

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