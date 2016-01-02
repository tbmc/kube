var app = angular.module('app', ['ui.bootstrap', /*'ngCookies',*/ 'ngResource', 'ngRoute',
    'ngAnimate', 'luegg.directives', 'duScroll', /*"angularFileUpload"*/])

window.api_server = 'https://okapi.bdetl.org/'


// Permet d'activer la touche entrer pour effectuer une action autre que retour à la ligne
app.directive('ngEnter', function () {
    return function (scope, element, attrs) {
        element.bind("keydown keypress", function (event) {
            if(event.which === 13 && !event.shiftKey) {
                scope.$apply(function (){
                    scope.$eval(attrs.ngEnter);
                });
                event.preventDefault();
            }
        });
    };
});

app.filter('removeExtension', ['$filter', function($filter) {
    return function(fileName, ext) {
        var i;
        if(ext)
            i = fileName.lastIndexOf(ext)
        else
            i = fileName.lastIndexOf(".")
        if(i === -1)
            return fileName
        else
            return fileName.slice(0, i)
    }
}])

app.directive('fileModel', ['$parse', function ($parse) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var model = $parse(attrs.fileModel);
            var modelSetter = model.assign;
            
            element.bind('change', function(){
                scope.$apply(function(){
                    modelSetter(scope, element[0].files[0]);
                });
            });
        }
    };
}]);

app.service('fileUpload', ['preparedRequest', function (pr) {
    this.uploadFileToUrl = function(file, uploadUrl, name, parent, callback){
        var fd = new FormData();
        fd.append('file', file);
        fd.append("name", name)
        fd.append("parent", parent)
        //fd.append("creator", 1)

        var http = pr();
        http.post(uploadUrl, fd, {
            transformRequest: angular.identity,
            processData: false,
            headers: {
                "Content-Type": undefined, //"multipart/form-data; boundary=-------border",
                "Accept": "*/*"
            }
        })
        .success(function(){
            callback(true)
        })
        .error(function(){
            callback(false)
        });
    }
}]);

function refreshAngular($scope) {
    if(!$scope) return
    if(!$scope.$$phase)
        $scope.$apply()
}

app.directive("dropzone", function() {
    return {
        restrict: "A",
        link: function($scope, elem) {
            //elem.attr("style", "background-color: orange;")
            elem.bind("drop", function(evt) {
                evt.stopPropagation()
                evt.preventDefault()

                var files = evt.dataTransfer.files
                console.log(files)
                for(var i = 0, f; f = files[i]; i++) {

                }
            })
        }
    }
})

function resizeIframe(obj) {
    obj.style.height = obj.contentWindow.document.body.scrollHeight + "px"
}
