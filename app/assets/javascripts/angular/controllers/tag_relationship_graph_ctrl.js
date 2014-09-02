App.controller('TagRelationshipGraphCtrl', ['$scope', '$http', function($scope, $http){
    $scope.graphShow = null;

    $scope.showGraph = function(chart){
        $scope.graphShow = chart;
        console.log($scope.graphShow)
    }

    updateNodePositions2 = function(n, nodePositionDictionary){
        nodes = []
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
        return nodes
    }

    d3.json('/tags/' + window.gon.tag_id + '/tag_relationships.json', function(error, data) {
        $scope.graphsPresent = data.tag_relationships
        var graphs = data.graphs

        angular.forEach(data.tag_relationships, function(graph, index){

            var width = 650,
            height = 400;

            var cluster = d3.layout.cluster()
                .size([height, width/2]);

            var svg = d3.select("#" + graph.paramaterized + "_d3_graph").append("svg")
                .attr("width", width + 50)
                .attr("height", height)
                .append("g")
                .attr("transform", "translate("+ width/2 + ",0)");

            var rootLeft = {children: [], name: graphs[graph.name].name}
            var rootRight = {children: [], name: graphs[graph.name].name}
            var nodePositionDictionary = {};

            angular.forEach(graphs[graph.name].parents, function(parent, index){
                rootLeft.children.push(parent);
            });
            angular.forEach(graphs[graph.name].children, function(child, index){
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

            
            nodes = updateNodePositions2(graphs[graph.name], nodePositionDictionary);

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
        })
    })
}]);