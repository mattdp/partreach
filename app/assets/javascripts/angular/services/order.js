App.factory('Order', ['$resource', function($resource){
    return $resource('/orders/:id.json', null,
            // We currently don't have just one update on orders, but several..., so this method is a placeholder
            // for future OrdersController refactoring.
            {
                'update': {method: 'PUT'}
            });
}]);