App.controller('TagRelationshipGraphCtrl', ['$scope', '$http', function($scope, $http){
    $scope.graphShow = null;

    $scope.showGraph = function(chart){
        $scope.graphShow = chart;
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

            larger = graphs[graph.name].parents > graphs[graph.name].children ? graphs[graph.name].parents.length : graphs[graph.name].children.length
            var width = 700,
            height = larger < 4 ? 60 : larger * 20;

            var cluster = d3.layout.cluster()
                .size([height, width/2 - 100]);

            var svg = d3.select("#" + graph.paramaterized + "_d3_graph").append("svg")
                .attr("width", width)
                .attr("height", height)
                .append("g")
                .attr("transform", "translate("+ width/2 + ",0)");

            var rootLeft = {children: [], name: graphs[graph.name].name, id: graphs[graph.name].id}
            var rootRight = {children: [], name: graphs[graph.name].name, id: graphs[graph.name].id}
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

            var diagonalRight = d3.svg.diagonal().projection(function(d) { return [(d.y), d.x]; });
            var diagonalLeft = d3.svg.diagonal().projection(function(d) { return [(-d.y), d.x]; });
            var links = cluster.links(nodes);
            var link = svg.selectAll(".link")
                .data(links)
                .enter().append("path")
                .attr("class", "link")
                .attr("d", function(d){return d.target.right || d.source.right ? diagonalRight(d) : diagonalLeft(d); });

            var node = svg.selectAll(".node")
                .data(nodes)
                .enter().append("g")
                .on("click", function(d,i) { window.location.href = '/tags/' + d.id + '/edit' })
                .on("mouseover", function(){ $(this).css('cursor', 'pointer');})
                .attr("class", "node")
                .attr("transform", function(d) { return d.right ? "translate(" + (d.y) + "," + d.x + ")" : "translate(" + (-d.y) + "," + d.x + ")" ; })

            node.append("circle")
                .attr("r", 4.5);

            node.append("text")
                .on("click", function(d,i) { window.location.href = '/tags/' + d.id + '/edit' })
                .on("mouseover", function(){ $(this).css('cursor', 'pointer');})
                .attr("dx", function(d) { if ( d.right === false){return -8}else if (d.right === true){return 8}else {return 0} })
                .attr("dy", function(d) { return d.right === undefined ? -10 : 3; })
                .style("text-anchor", function(d) { if ( d.right === false){return "end"}else if (d.right === true){return "start"}else {return "middle"} })
                .text(function(d) { return d.name; });
        })
    })
}]);