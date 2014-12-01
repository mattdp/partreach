App.controller('AdminDashboardCtrl', ['$scope', '$http', function($scope, $http){
    $scope.newEmail = null;
    $scope.newName = null;
    $scope.interactionMeans = null;


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
        {displayText: 'Recommended', attribute: 'recommended'},
        {displayText: 'Billable', attribute: 'billable'}
    ]

    orderAttributes = [
        'process_confidence',
        'recommendation',
        'notes',
        'columns_shown',
        'next_steps',
        'status',
        'next_action_date',
    ]

    $scope.pastExperienceOptions = [
        "Unknown",
        "Positive",
        "Provisional",
        "Mixed"
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
        $scope.notes = "RFQ"+order.id + " - "
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
    serializeDialoguesParams = function(){
        updateParams = {id: $scope.order.id}
        angular.forEach(orderAttributes, function(value, index){
            updateParams[value] = $scope.order[value]
        });
        angular.forEach($scope.order.order_groups, function(og, index){      
            angular.forEach(og.alphabetical_dialogues, function(dialogue, index){
                updateParams[dialogue.id] = {order_group_id: og.id, supplier_id: dialogue.supplier_id}
                angular.forEach($scope.checkboxes, function(cHash, index){
                    updateParams[dialogue.id][cHash.attribute] = dialogue[cHash.attribute]
                });
                angular.forEach($scope.headers, function(hHash, index){
                    updateParams[dialogue.id][hHash.attribute] = dialogue[hHash.attribute]
                });
                updateParams[dialogue.id]["past_experience"] = dialogue.past_experience
            });
        });
        return updateParams
    }

    $scope.manipulateDialog = function(){
        updateParams = serializeDialoguesParams()
        $http.post('/orders/update_dialogues', updateParams)
    }

    $scope.removeDialogue = function(id, dialogueIndex, ogIndex){
        if (confirm('Sun Tzu says: Deleting dialogue is forever.') ){
            $http.delete('/dialogues/' + id + '.json').success(function(data){
                if (data.success === true){
                    $scope.order.order_groups[ogIndex].alphabetical_dialogues.splice(dialogueIndex,1)
                }
            })
        }
    }

    $scope.createCommunication = function(interactionMeans, notes){
        postParams = {
            communicator_type: 'Lead', 
            communicator_id: $scope.order.user.lead.id,
            means_of_interaction: interactionMeans,
            notes: notes
        }
        $http.post('/communications.json', postParams).success(function(data){
            if (data.success === true){
                $scope.order.user.lead.communications.unshift(data.communication)
            }
            $scope.notes = "RFQ" + $scope.order.id + " - "
            $scope.interactionMeans = null;
        })
    }
}]);