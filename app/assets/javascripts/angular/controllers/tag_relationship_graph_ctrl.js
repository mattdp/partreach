App.controller('tagRelationshipGraphCtrl', ['$scope', '$http', function($scope, $http){
    $scope.graphShow = 'typeOf'

    $scope.showGraph = function(chart){
        $scope.graphShow = chart;
    }

    $scope.graphData = {
        name: 'Root',
        children: [
            {
                name: 'Child1'
            },
            {
                name: 'Child2'
            },
            {
                name: 'Child3'
            }
        ],
        parents: [
            {
                name: 'Parent1'
            },
            {
                name: 'Parent2'
            },
            {
                name: 'Parent3'
            }
        ] 
    }

    updateNodePositions = function(n){
        var nodePosition = nodePositionDictionary[n.name + (n.parent?n.parent.name:"")];

        if(nodePosition){
            n.x = nodePosition.x;
            n.y = nodePosition.y;
            n.depth = nodePosition.depth;
            nodes.push(n);
        }

        angular.forEach(n.children, function(node, index){
            node.parent = n;

            nodes.push(node);

            var childNodePosition = nodePositionDictionary[node.name + (node.parent?node.parent.name:"")];
            if(childNodePosition){
                node.x = childNodePosition.x;
                node.y = childNodePosition.y;
                node.depth = childNodePosition.depth;
                node.right = childNodePosition.right;
            }
        });
        angular.forEach(n.parents, function(node, index){
            node.parent = n;

            nodes.push(node);

            var childNodePosition = nodePositionDictionary[node.name + (node.parent?node.parent.name:"")];
            if(childNodePosition){
                node.x = childNodePosition.x;
                node.y = childNodePosition.y;
                node.depth = childNodePosition.depth;
                node.right = childNodePosition.right;
            }
            n.children.push(node)
        });
    }

    var width = 650,
    height = 400;

    var cluster = d3.layout.cluster()
        .size([height, width/2]);

    var svg = d3.select("#type-of-d3-graph").append("svg")
        .attr("width", width + 50)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate("+ width/2 + ",0)");

    var rootLeft = {children: [], name: $scope.graphData.name}
    var rootRight = {children: [], name: $scope.graphData.name}
    var nodePositionDictionary = {};

    angular.forEach($scope.graphData.parents, function(parent, index){
        rootLeft.children.push(parent);
    });
    angular.forEach($scope.graphData.children, function(child, index){
      rootRight.children.push(child);
    });

    var nodesRight = cluster.nodes(rootRight);
    angular.forEach(nodesRight, function(node, index){
      node.right = true;
      nodePositionDictionary[node.name + (node.parent ? node.parent.name : "")] = node;
    })
    var nodesLeft = cluster.nodes(rootLeft);
    angular.forEach(nodesLeft, function(node, index){
      node.right = false;
      nodePositionDictionary[node.name + (node.parent ? node.parent.name : "")] = node;
    })

    var nodes = [];
    updateNodePositions($scope.graphData);

    var diagonalRight = d3.svg.diagonal().projection(function(d) { return [d.y, d.x]; });
    var diagonalLeft = d3.svg.diagonal().projection(function(d) { return [(-d.y+10), d.x]; });
    var links = cluster.links(nodes);
    var link = svg.selectAll(".link")
        .data(links)
        .enter().append("path")
        .attr("class", "link")
        .attr("d", function(d){return d.target.right || d.source.right ? diagonalRight(d) : diagonalLeft(d); });

    var node = svg.selectAll(".node")
        .data(nodes)
        .enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d) { return d.right ? "translate(" + d.y + "," + d.x + ")" : "translate(" + (-d.y+10) + "," + d.x + ")" ; })

    node.append("circle")
        .attr("r", 4.5);

    node.append("text")
        .attr("dx", function(d) { return d.children ? -8 : 8; })
        .attr("dy", 3)
        .style("text-anchor", function(d) { return d.children ? "end" : "start"; })
        .text(function(d) { return d.name; });

}]);