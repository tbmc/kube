
app.controller 'filesController', ['$scope', "preparedRequest",
'$window', '$routeParams', "$uibModal",
($scope, pr, $window, $routeParams, $uibModal) ->
	
	#console.log $routeParams.filename, $routeParams.path

	$scope.path = [
		{
			name: 'Home'
			path: '/'
		}
		{
			name: 'Library'
			path: '/home'
		}
		{
			name: 'Data'
			path: '/home/Library'
		}
	]

	refreshFiles = ->
		http = pr()
		http.get(window.api_server + "share/files/").
		success((data) ->
			#console.log data
		)

	$scope.openUploadModal = ->
		
		upModal = $uibModal.open({
			animation: true
			templateUrl: "uploadFileModel.html"
			controller: "ModalUploadFileController"
			size: "lg"
			backdrop: "static"
		})


	refreshFiles()
]

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