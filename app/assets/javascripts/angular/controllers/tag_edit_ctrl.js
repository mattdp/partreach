App.controller('TagEditCtrl', ['$scope', '$http', function($scope, $http){
    $http.get('/tag_relationship_types.json').success(function(data){
        $scope.relationshipTypes = data
    });

    $http.get('/tags/' + window.gon.tag_id + '.json').success(function(data){
        $scope.tag = data.tag;
        $scope.processTags = data.process_tags
    });

    $scope.selectTag = function(tagId, relationshipTypeId){
      postParams = {
          tag_relationship: {
              source_tag_id: window.gon.tag_id,
              related_tag_id: tagId,
              tag_relationship_type_id: relationshipTypeId
          }
      }
      $http.post('/tags/' + window.gon.tag_id + '/tag_relationships.json', postParams).success(function(data){
          if (data.success === true){
              location.reload();
          }
      })
    }
}]);