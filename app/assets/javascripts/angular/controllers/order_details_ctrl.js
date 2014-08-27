App.controller('OrderDetailsCtrl', ['$scope', '$http', function($scope, $http){
    $scope.newEmail = null;
    $scope.newName = null;


    // I could combine headers and checkboxes into one dialogueAttributes array that has a 'type'
    // key that differentiates whether it's a text input or a checkbox
    $scope.headers = [
        {displayText: 'Material', attribute: 'material'},
        {displayText: 'Process Name', attribute: 'process_name'}, 
        {displayText: 'Process Time', attribute: 'process_time'}, 
        {displayText: 'Shipping Name', attribute: 'shipping_name'}, 
        {displayText: 'Notes', attribute: 'notes'}, 
        {displayText: 'Currency', attribute: 'currency'}, 
        {displayText: 'Internal Notes', attribute: 'internal_notes'}, 
        {displayText: 'Order Group ID', attribute: 'order_group_id'}, 
        {displayText: 'Supplier ID', attribute: 'supplier_id'}, 
        {displayText: 'Process Cost', attribute: 'process_cost'}, 
        {displayText: 'Shipping Cost', attribute: 'shipping_cost'}, 
        {displayText: 'Total Cost', attribute: 'total_cost'}
    ]

    $scope.checkboxes = [
        {displayText: 'Initial Select', attribute: 'initial_select'},
        {displayText: 'Opener Sent', attribute: 'opener_sent'},
        {displayText: 'Supplier Working', attribute: 'supplier_working'},
        {displayText: 'Response Received', attribute: 'response_received'},
        {displayText: 'Informed', attribute: 'informed'},
        {displayText: 'Won', attribute: 'won'},
        {displayText: 'Recommended', attribute: 'recommended'}
    ]

    orderAttributes = [
        'recommendation',
        'notes',
        'columns_shown',
        'next_steps',
        'status',
        'next_action_date',
    ]

    $scope.orderStatusOptions = [
        "Needs work",
        "Waiting for supplier",
        "Waiting for buyer",
        "Need to inform suppliers",
        "Finished - closed",
        "Finished - no close"
    ]

    $scope.columnsShownOptions = [
        "all",
        "speed",
        "cost",
        "quality"
    ]


    $http.get('/manipulate/' + window.gon.order_id + '.json').success(function(order){
        $scope.order = order
        console.log(order)
    });

    $scope.transferOrder = function(newEmail, newName){
        $scope.newEmail = null;
        $scope.newName = null;
        postParams = {order_id: $scope.order.id, new_owner_email: newEmail, new_owner_name: newName}
        $http.post('/transfer_orders.json', postParams).success(function(order){
            $scope.order = order
        });
    }

    // Would rather have update_dialogues accept_nested_attributes_for :dialogues
    serializeParams = function(){
        updateParams = {id: $scope.order.id}
        angular.forEach(orderAttributes, function(value, index){
            updateParams[value] = $scope.order[value]
        });
        angular.forEach($scope.order.order_groups, function(og, index){      
            angular.forEach(og.alphabetical_dialogues, function(dialogue, index){
                updateParams[dialogue.id] = {}
                angular.forEach($scope.checkboxes, function(cHash, index){
                    updateParams[dialogue.id][cHash.attribute] = dialogue[cHash.attribute]
                });
                angular.forEach($scope.headers, function(hHash, index){
                    updateParams[dialogue.id][hHash.attribute] = dialogue[hHash.attribute]
                });
            });
        });
        console.log(updateParams)
        return updateParams
    }

    $scope.manipulateDialog = function(){
        updateParams = serializeParams()
        $http.post('/orders/update_dialogues', updateParams)
    }
}]);