var app = angular.module('app', ['ui.bootstrap', 'ngCookies', 'ngResource', 'ngRoute',
    'ngAnimate', 'luegg.directives', 'duScroll', "angularFileUpload"])
window.api_server = 'http://okapi.bdetl.org/'


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

/*
app.directive('scrollchat', function() {
    return {
        priority: 1,
        link: function(scope, element, attrs) {
                element.attr('scroll-glue', true)
                element.bind("scroll", function() {
                    var max = element.prop('scrollHeight') - element.prop('clientHeight')
                    var s = element.scrollTop()
                    if(max === s)
                        element.attr('scroll-glue', true)
                    else
                        element.attr('scroll-glue', false)
                })
            }
    }
})
*/