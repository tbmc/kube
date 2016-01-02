
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

	$scope.loadDirectory = (dir_id, notAdd, notRemoveWhenLoading) ->
		$scope.loading += 3
		loadPath(dir_id, notAdd)
		loadDirectory(dir_id, notRemoveWhenLoading)
		loadFiles(dir_id, notRemoveWhenLoading)

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

	loadDirectory = (dir_id, notRemoveWhenLoading) ->
		if !notRemoveWhenLoading
			$scope.folders = []
		http = pr()
		http.get(window.api_server + directoryRoute + "?parent=" + dir_id).
			success( (data) ->
				$scope.folders = toPrintArray(data)
				$scope.loading-- 
			)
	loadFiles = (dir_id, notRemoveWhenLoading) ->
		if !notRemoveWhenLoading
			$scope.files = []
		http = pr()
		http.get(window.api_server + fileRoute + "?parent=" + dir_id).
			success( (data) ->
				$scope.files = toPrintArray(data)
				$scope.loading-- 
			)

	style = "border: none; width: 100%; height: 100%;"
	$scope.printFile = (id, url, name, path_ids) ->
		$scope.loading++
		$scope.pathToSelectedFile = {
			url: url
			path_ids: path_ids
			name: name
		}
		eid = "iframeContent"
		e = document.getElementById(eid)
		if e
			parent = e.parentElement
			parent.removeChild(e)
		parent = document.getElementById("embedContainer")
		embed = document.createElement("EMBED")
		parent.appendChild(embed)
		embed.setAttribute("style", style)
		embed.setAttribute("id", eid)
		downloadAsBlob(url, name, (data) ->
			e = document.getElementById("iframeContent")
			urlFile = URL.createObjectURL(data)
			e.setAttribute("src", urlFile)
			e.setAttribute("style", style + "height:" + $scope.containerFrameHeight.height + ";")
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
			resolve: {
				folder_id: ->
					return actual_folder
			}
		})
		up.result.then((data) ->
			$scope.refresh()
		)

	$scope.refresh = ->
		$scope.loadDirectory(actual_folder, true, true)

	resizeWindow = ->
		w = $window.innerWidth
		h = $window.innerHeight
		el = document.getElementById("iframeContent")
		if w >= 992 && el
			top = el.getBoundingClientRect().top
			$scope.containerFrameHeight = {
				height: (h - top - 100) + "px"
			}
			el.setAttribute("style", style + "height:" + $scope.containerFrameHeight.height + ";")
		else if el
			$scope.containerFrameHeight = {
				"min-height": "500px"
			}
			el.setAttribute("style", style + "min-height:500px")
		refreshAngular($scope)

	angular.element($window).bind("resize", ->
		resizeWindow()
	)
	angular.element(document).ready(->
		resizeWindow()
	)
	$scope.download = (url, name) ->
		downloadAsBlob(url, name, (data) ->
			saveAs(data, name, true)
		)

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

]

app.controller("uploadControllerPopupController",
["$scope", "$uibModalInstance", "fileUpload",
"directoryCache", "preparedRequest", "folder_id"
($scope, $uibModalInstance, fileUpload, directoryCache, pr, folder_id) ->

	$scope.uploadLoading = false
	$scope.folder = {
		id: []
		path_ids: []
	}
	$scope.folder_id = folder_id
	$scope.cache = directoryCache

	http = pr()
	http.get(window.api_server + directoryRoute + folder_id + "/").
	success((data) ->
		$scope.folder = {
			path_ids: data.path_ids
			id: data.id
		}
	)

	$scope.close = ->
		$uibModalInstance.close({
			
		})

	$scope.uploadFile = ->
		$scope.uploadLoading = true
		uploadUrl = window.api_server + fileRoute
		fu = $scope.fileToUpload
		fileUpload.uploadFileToUrl(fu, uploadUrl, fu.name, $scope.folder_id, (success) ->
			if success
				$scope.uploadLoading = false
		)

])




###
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
###

