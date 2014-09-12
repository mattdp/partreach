App.controller('OrderQuestionsCtrl', ['$scope', 'UrlParams', function($scope, UrlParams){
    $scope.selectedRadio = {
        experience: UrlParams('experience'),
        priority: UrlParams('priority'),
        manufacturing: UrlParams('manufacturing')
    }

    $scope.options = [
        {
            attribute: "experience",
            values: {
                experienced: {
                    value: "experienced",
                    summary: "am experienced",
                    punchy: "Experienced",
                    detail: "I know the details. Let me tell you exactly what I need."
                },
                rookie: {
                    value: "rookie",
                    summary: "am still learning",
                    punchy: "Still learning",
                    detail: "I'm not sure what's best for the job. I could use a little help."
                }
            }
        },
        {
            attribute: "priority",
            values: {
                speed: {
                  value: "speed",
                  summary: "speed",
                  punchy: "Speed",
                  detail: "This needs to be done soon."
                },
                quality: {
                  value: "quality",
                  summary: "quality",
                  punchy: "Quality",
                  detail: "The details have to be exactly right."
                },
                cost:{
                  value: "cost",
                  summary: "cost",
                  punchy: "Cost",
                  detail: "Find me an inexpensive supplier."
                }
            }
        },
        {
            attribute: 'manufacturing',
            values: {
                printing: {
                  value: "printing",
                  summary: "should be",
                  punchy: "3D printing",
                  detail: "I think this should be 3D printed."
                },
                other: {
                  value: "other",
                  summary: "shouldn't be",
                  punchy: "Some other method",
                  detail: "3D printing isn't appropriate for this."
                },
                unknown: {
                  value: "unknown",
                  summary: "might be",
                  punchy: "I don't know",
                  detail: "I don't know what's best."
                }
            }
        }
    ]
}]);