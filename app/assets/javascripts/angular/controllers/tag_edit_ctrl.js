App.controller('TagEditCtrl', ['$scope', '$http', function($scope, $http){
    $http.get('tags' + window.gon.tag_id).success(function(data){
        $scope.tag = data.tag;
        $scope.processTags = data.process_tags
        console.log(data)
    });

}]);