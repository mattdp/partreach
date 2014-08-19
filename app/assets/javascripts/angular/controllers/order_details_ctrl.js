App.controller('OrderDetailsCtrl', ['$scope', '$http', function($scope, $http){
    $http.get('/manipulate/' + window.gon.order_id + '.json').success(function(order){
        $scope.order = order
    })

    $scope.transferOrder = function(newEmail){
        postParams = {order_id: $scope.order.id, new_owner_email: newEmail}
        $http.post('/transfer_orders.json', postParams).success(function(order){
            $scope.order = order
        });
    }
}]);