App.controller('OrderDetailsCtrl', ['$scope', '$http', function($scope, $http){
    $scope.newEmail = null;
    $scope.newName = null;

    $http.get('/manipulate/' + window.gon.order_id + '.json').success(function(order){
        $scope.order = order
        console.log(order)
    })

    $scope.transferOrder = function(newEmail, newName){
        $scope.newEmail = null;
        $scope.newName = null;
        postParams = {order_id: $scope.order.id, new_owner_email: newEmail, new_owner_name: newName}
        $http.post('/transfer_orders.json', postParams).success(function(order){
            $scope.order = order
        });
    }
}]);